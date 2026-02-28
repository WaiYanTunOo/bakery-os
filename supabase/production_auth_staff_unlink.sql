-- =========================================================
-- BakeryOS Production: Explicit Staff/Auth Unlink Function
-- =========================================================
-- Offboarding companion migration for staff_auth_bindings.
-- Enforces non-empty reason and writes unlink audit rows.

CREATE OR REPLACE FUNCTION public.deactivate_staff_auth_binding(
  p_performed_by TEXT,
  p_reason TEXT,
  p_staff_id TEXT DEFAULT NULL,
  p_auth_user_id UUID DEFAULT NULL
) RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  IF trim(coalesce(p_reason, '')) = '' THEN
    RAISE EXCEPTION 'Offboarding reason is required';
  END IF;

  IF trim(coalesce(p_performed_by, '')) = '' THEN
    RAISE EXCEPTION 'performed_by is required';
  END IF;

  IF p_staff_id IS NULL AND p_auth_user_id IS NULL THEN
    RAISE EXCEPTION 'Either staff_id or auth_user_id must be provided';
  END IF;

  WITH deactivated AS (
    UPDATE public.staff_auth_bindings
       SET is_active = FALSE
     WHERE is_active
       AND (
         (p_staff_id IS NOT NULL AND staff_id = p_staff_id)
         OR (p_auth_user_id IS NOT NULL AND auth_user_id = p_auth_user_id)
       )
    RETURNING id, staff_id, auth_user_id, email, app_role
  )
  INSERT INTO public.staff_auth_binding_audit(
    binding_id, action, staff_id, auth_user_id, email, app_role, performed_by, reason
  )
  SELECT id, 'unlink', staff_id, auth_user_id, email, app_role, trim(p_performed_by), trim(p_reason)
  FROM deactivated;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

REVOKE ALL ON FUNCTION public.deactivate_staff_auth_binding(TEXT, TEXT, TEXT, UUID) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.deactivate_staff_auth_binding(TEXT, TEXT, TEXT, UUID) TO service_role;
