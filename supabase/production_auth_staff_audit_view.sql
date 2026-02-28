-- =========================================================
-- BakeryOS Production: Read-Only Staff/Auth Audit View
-- =========================================================
-- Shows active bindings with latest audit action for admin review.

CREATE OR REPLACE VIEW public.v_staff_auth_active_with_last_audit
WITH (security_barrier = true)
AS
SELECT
  b.id AS binding_id,
  b.staff_id,
  s.name AS staff_name,
  b.auth_user_id,
  b.email,
  b.app_role,
  b.linked_by,
  b.linked_at,
  a.action AS last_action,
  a.performed_by AS last_action_by,
  a.performed_at AS last_action_at,
  a.reason AS last_action_reason
FROM public.staff_auth_bindings b
JOIN public.staff_directory s
  ON s.id = b.staff_id
LEFT JOIN LATERAL (
  SELECT action, performed_by, performed_at, reason
  FROM public.staff_auth_binding_audit
  WHERE binding_id = b.id
  ORDER BY performed_at DESC, id DESC
  LIMIT 1
) a ON true
WHERE b.is_active = true;

REVOKE ALL ON public.v_staff_auth_active_with_last_audit FROM PUBLIC, anon;
GRANT SELECT ON public.v_staff_auth_active_with_last_audit TO service_role;
