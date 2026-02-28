-- =========================================================
-- BakeryOS Production Hardening: Orders & Showcase RLS
-- =========================================================

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
USING (public.current_app_role() IN ('BH', 'Owner'))
WITH CHECK (
  public.current_app_role() IN ('BH', 'Owner')
  AND status IN ('pending', 'verified', 'in_progress', 'ready')
);

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
