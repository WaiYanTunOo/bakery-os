-- =========================================================
-- BakeryOS Production Hardening: EOD & Expense RLS
-- =========================================================

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
