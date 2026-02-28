-- =========================================================
-- BakeryOS Production DB Hardening (Idempotent)
-- =========================================================
-- Apply this script after base schema is created.
-- It adds stricter integrity constraints and includes
-- production RLS policy templates aligned with app-side guards.
--
-- Safe to run multiple times.

-- ---------------------------------------------------------
-- 1) STRICTER TABLE CONSTRAINTS
-- ---------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'staff_directory_role_check'
  ) THEN
    ALTER TABLE public.staff_directory
      ADD CONSTRAINT staff_directory_role_check
      CHECK (role IN ('FH', 'BH', 'Owner'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'online_orders_status_check'
  ) THEN
    ALTER TABLE public.online_orders
      ADD CONSTRAINT online_orders_status_check
      CHECK (status IN ('pending', 'verified'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'online_orders_total_nonnegative_check'
  ) THEN
    ALTER TABLE public.online_orders
      ADD CONSTRAINT online_orders_total_nonnegative_check
      CHECK (total >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'online_orders_items_array_check'
  ) THEN
    ALTER TABLE public.online_orders
      ADD CONSTRAINT online_orders_items_array_check
      CHECK (jsonb_typeof(items) = 'array' AND jsonb_array_length(items) > 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'showcase_requests_status_check'
  ) THEN
    ALTER TABLE public.showcase_requests
      ADD CONSTRAINT showcase_requests_status_check
      CHECK (status IN ('pending', 'delivered'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'showcase_requests_delivered_qty_check'
  ) THEN
    ALTER TABLE public.showcase_requests
      ADD CONSTRAINT showcase_requests_delivered_qty_check
      CHECK (delivered_qty IS NULL OR delivered_qty >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'showcase_requests_delivery_fields_check'
  ) THEN
    ALTER TABLE public.showcase_requests
      ADD CONSTRAINT showcase_requests_delivery_fields_check
      CHECK (
        (status = 'pending' AND time_delivered IS NULL AND delivered_by IS NULL)
        OR (status = 'delivered')
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'expenses_qty_positive_check'
  ) THEN
    ALTER TABLE public.expenses
      ADD CONSTRAINT expenses_qty_positive_check
      CHECK (qty >= 1);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'expenses_unit_price_nonnegative_check'
  ) THEN
    ALTER TABLE public.expenses
      ADD CONSTRAINT expenses_unit_price_nonnegative_check
      CHECK (unit_price IS NULL OR unit_price >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'expenses_total_nonnegative_check'
  ) THEN
    ALTER TABLE public.expenses
      ADD CONSTRAINT expenses_total_nonnegative_check
      CHECK (total IS NULL OR total >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'eod_reports_nonnegative_check'
  ) THEN
    ALTER TABLE public.eod_reports
      ADD CONSTRAINT eod_reports_nonnegative_check
      CHECK (
        gross_sales >= 0
        AND promptpay >= 0
        AND card >= 0
        AND expected_cash >= 0
        AND actual_cash >= 0
        AND discrepancy >= 0
      );
  END IF;
END $$;

-- ---------------------------------------------------------
-- 2) PRODUCTION RLS POLICY TEMPLATE
-- ---------------------------------------------------------
-- IMPORTANT:
-- 1) Keep current development allow-all policies for mock login.
-- 2) When enabling production, remove allow-all policies first.
-- 3) Configure JWT custom claims: app_role and staff_name.
--
-- Suggested claim mapping:
--   app_role   -> Owner | FH | BH
--   staff_name -> exact staff member name stored in logged_by/requested_by

/*
-- Example helper function for claims
CREATE OR REPLACE FUNCTION public.current_app_role()
RETURNS TEXT
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(auth.jwt()->>'app_role', '');
$$;

CREATE OR REPLACE FUNCTION public.current_staff_name()
RETURNS TEXT
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(auth.jwt()->>'staff_name', '');
$$;

-- DROP development allow-all policies (exact names from schema.sql)
DROP POLICY IF EXISTS "Allow all operations for menu_items" ON public.menu_items;
DROP POLICY IF EXISTS "Allow all operations for staff" ON public.staff_directory;
DROP POLICY IF EXISTS "Allow all operations for eod" ON public.eod_reports;
DROP POLICY IF EXISTS "Allow all operations for orders" ON public.online_orders;
DROP POLICY IF EXISTS "Allow all operations for expenses" ON public.expenses;
DROP POLICY IF EXISTS "Allow all operations for showcase" ON public.showcase_requests;

-- MENU ITEMS
CREATE POLICY menu_items_read_auth
ON public.menu_items
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY menu_items_write_owner
ON public.menu_items
FOR ALL
TO authenticated
USING (public.current_app_role() = 'Owner')
WITH CHECK (public.current_app_role() = 'Owner');

-- STAFF DIRECTORY
CREATE POLICY staff_directory_read_auth
ON public.staff_directory
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY staff_directory_write_owner
ON public.staff_directory
FOR ALL
TO authenticated
USING (public.current_app_role() = 'Owner')
WITH CHECK (public.current_app_role() = 'Owner');

-- ONLINE ORDERS
CREATE POLICY online_orders_read
ON public.online_orders
FOR SELECT
TO authenticated
USING (
  public.current_app_role() IN ('Owner', 'BH')
  OR logged_by = public.current_staff_name()
);

CREATE POLICY online_orders_insert
ON public.online_orders
FOR INSERT
TO authenticated
WITH CHECK (
  public.current_app_role() IN ('FH', 'Owner')
  AND logged_by = public.current_staff_name()
  AND status IN ('pending', 'verified')
);

CREATE POLICY online_orders_verify_owner
ON public.online_orders
FOR UPDATE
TO authenticated
USING (public.current_app_role() = 'Owner')
WITH CHECK (public.current_app_role() = 'Owner' AND status IN ('pending', 'verified'));

-- SHOWCASE REQUESTS
CREATE POLICY showcase_read
ON public.showcase_requests
FOR SELECT
TO authenticated
USING (public.current_app_role() IN ('Owner', 'FH', 'BH'));

CREATE POLICY showcase_insert_fh_owner
ON public.showcase_requests
FOR INSERT
TO authenticated
WITH CHECK (
  public.current_app_role() IN ('FH', 'Owner')
  AND requested_by = public.current_staff_name()
  AND status = 'pending'
);

CREATE POLICY showcase_update_bh_owner
ON public.showcase_requests
FOR UPDATE
TO authenticated
USING (public.current_app_role() IN ('BH', 'Owner'))
WITH CHECK (
  public.current_app_role() IN ('BH', 'Owner')
  AND status IN ('pending', 'delivered')
);

-- EOD + EXPENSES (owner and operator visibility)
CREATE POLICY eod_read_auth
ON public.eod_reports
FOR SELECT
TO authenticated
USING (public.current_app_role() IN ('Owner', 'FH', 'BH'));

CREATE POLICY eod_write_owner_fh
ON public.eod_reports
FOR INSERT
TO authenticated
WITH CHECK (public.current_app_role() IN ('Owner', 'FH'));

CREATE POLICY expenses_read_auth
ON public.expenses
FOR SELECT
TO authenticated
USING (public.current_app_role() IN ('Owner', 'FH', 'BH'));

CREATE POLICY expenses_insert_auth
ON public.expenses
FOR INSERT
TO authenticated
WITH CHECK (public.current_app_role() IN ('Owner', 'FH', 'BH'));
*/

-- End of production hardening template.
