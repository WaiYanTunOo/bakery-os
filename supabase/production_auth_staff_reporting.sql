-- =========================================================
-- BakeryOS Production: Backend Audit Reporting Function
-- =========================================================
-- Backend-only report accessor with optional filters:
--   role, email, date range over COALESCE(last_action_at, linked_at)

CREATE OR REPLACE FUNCTION public.get_staff_auth_audit_report(
  p_role TEXT DEFAULT NULL,
  p_email TEXT DEFAULT NULL,
  p_from_date DATE DEFAULT NULL,
  p_to_date DATE DEFAULT NULL,
  p_limit INTEGER DEFAULT 500
) RETURNS TABLE (
  binding_id BIGINT,
  staff_id TEXT,
  staff_name TEXT,
  auth_user_id UUID,
  email TEXT,
  app_role TEXT,
  linked_by TEXT,
  linked_at TIMESTAMPTZ,
  last_action TEXT,
  last_action_by TEXT,
  last_action_at TIMESTAMPTZ,
  last_action_reason TEXT
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    v.binding_id,
    v.staff_id,
    v.staff_name,
    v.auth_user_id,
    v.email,
    v.app_role,
    v.linked_by,
    v.linked_at,
    v.last_action,
    v.last_action_by,
    v.last_action_at,
    v.last_action_reason
  FROM public.v_staff_auth_active_with_last_audit v
  WHERE (p_role IS NULL OR v.app_role = p_role)
    AND (p_email IS NULL OR lower(v.email) = lower(trim(p_email)))
    AND (
      p_from_date IS NULL
      OR COALESCE(v.last_action_at, v.linked_at)::date >= p_from_date
    )
    AND (
      p_to_date IS NULL
      OR COALESCE(v.last_action_at, v.linked_at)::date <= p_to_date
    )
  ORDER BY COALESCE(v.last_action_at, v.linked_at) DESC, v.binding_id DESC
  LIMIT GREATEST(1, LEAST(COALESCE(p_limit, 500), 5000));
$$;

REVOKE ALL ON FUNCTION public.get_staff_auth_audit_report(TEXT, TEXT, DATE, DATE, INTEGER)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_staff_auth_audit_report(TEXT, TEXT, DATE, DATE, INTEGER)
  TO service_role;
