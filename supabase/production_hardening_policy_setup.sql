-- =========================================================
-- BakeryOS Production Hardening: RLS Setup
-- =========================================================
-- Configure JWT claims before applying policies:
--   app_role   -> Owner | FH | BH
--   staff_name -> staff name used in logged_by/requested_by

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

DROP POLICY IF EXISTS "Allow all operations for menu_items" ON public.menu_items;
DROP POLICY IF EXISTS "Allow all operations for staff" ON public.staff_directory;
DROP POLICY IF EXISTS "Allow all operations for eod" ON public.eod_reports;
DROP POLICY IF EXISTS "Allow all operations for orders" ON public.online_orders;
DROP POLICY IF EXISTS "Allow all operations for expenses" ON public.expenses;
DROP POLICY IF EXISTS "Allow all operations for showcase" ON public.showcase_requests;

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
