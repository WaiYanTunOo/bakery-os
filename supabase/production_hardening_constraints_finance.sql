-- =========================================================
-- BakeryOS Production Hardening: Finance Constraints
-- =========================================================
DO $$
BEGIN
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
