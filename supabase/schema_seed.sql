-- ==========================================
-- BakeryOS Schema: Seed Data
-- ==========================================

INSERT INTO public.staff_directory (id, name, role, can_manage_products) VALUES
    ('s1', 'Khun Jane', 'FH', false),
    ('s2', 'Khun A', 'BH', false),
    ('s3', 'Khun Boy', 'FH', true),
    ('owner', 'Bakery Owner', 'Owner', true);

INSERT INTO public.menu_items (id, name, price) VALUES
    (1, 'Coconut Cake', 95.0),
    (2, 'Mango Mini', 95.0),
    (3, 'Rich Chocolate', 95.0),
    (4, 'Matcha Raspberry', 95.0),
    (5, 'Applepresso', 120.0);
