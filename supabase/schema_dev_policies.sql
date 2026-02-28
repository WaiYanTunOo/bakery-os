-- ==========================================
-- BakeryOS Schema: Development RLS Policies
-- ==========================================
-- NOTE: This is only for development / mock-login style environments.
-- Use production_hardening_* scripts for production-grade policies.

ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff_directory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.eod_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.online_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.showcase_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all operations for menu_items" ON public.menu_items FOR ALL USING (true);
CREATE POLICY "Allow all operations for staff" ON public.staff_directory FOR ALL USING (true);
CREATE POLICY "Allow all operations for eod" ON public.eod_reports FOR ALL USING (true);
CREATE POLICY "Allow all operations for orders" ON public.online_orders FOR ALL USING (true);
CREATE POLICY "Allow all operations for expenses" ON public.expenses FOR ALL USING (true);
CREATE POLICY "Allow all operations for showcase" ON public.showcase_requests FOR ALL USING (true);
