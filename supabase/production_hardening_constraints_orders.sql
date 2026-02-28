-- =========================================================
-- BakeryOS Production Hardening: Orders & Showcase Constraints
-- =========================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'staff_directory_role_check'
  ) THEN
    ALTER TABLE public.staff_directory
      ADD CONSTRAINT staff_directory_role_check
      CHECK (role IN ('FH', 'BH', 'Owner'));
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'online_orders_status_check'
  ) THEN
    ALTER TABLE public.online_orders
      DROP CONSTRAINT online_orders_status_check;
  END IF;

  ALTER TABLE public.online_orders
    ADD CONSTRAINT online_orders_status_check
    CHECK (status IN ('pending', 'verified', 'in_progress', 'ready'));

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
END $$;
