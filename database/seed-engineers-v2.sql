-- =========================================================================
-- DATABASE SEEDING (DML): Master Engineers Registry (سجل المهندسين الموحد)
-- Target DBMS: PostgreSQL (Version 12+)
-- Project: Engineers Syndicate Accounting System (Hasakah, Qamishli, Derik)
-- Description: Seeds the core registry with real engineers compiled from 
--              the official 3-branch directories, mapping disciplines to 
--              standard codes (CIV, ARC, ELE, MCH, WTR, GEO, GTK), 
--              preserving role qualifications ('مؤهل الدور'), ranks ('المرتبة'), 
--              and mutual fund statuses ('الصندوق المشترك').
-- =========================================================================

BEGIN;
-- Safeguard Alterations
ALTER TABLE engineers_registry ADD COLUMN IF NOT EXISTS role_qualification VARCHAR(150);
ALTER TABLE engineers_registry ADD COLUMN IF NOT EXISTS office_branch syndicate_branch_code;

-- Auto-populate office_branch from engineer_id prefix
CREATE OR REPLACE FUNCTION fn_auto_populate_engineer_office_branch()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.engineer_id LIKE '%-HAS-%' THEN
        NEW.office_branch := 'HAS'::syndicate_branch_code;
    ELSIF NEW.engineer_id LIKE '%-QAM-%' THEN
        NEW.office_branch := 'QAM'::syndicate_branch_code;
    ELSIF NEW.engineer_id LIKE '%-DER-%' THEN
        NEW.office_branch := 'DER'::syndicate_branch_code;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_populate_office_branch ON engineers_registry;
CREATE TRIGGER trg_auto_populate_office_branch
BEFORE INSERT ON engineers_registry
FOR EACH ROW
EXECUTE FUNCTION fn_auto_populate_engineer_office_branch();



-- Standard cleaner to prevent conflicts during test cycles
TRUNCATE TABLE engineers_registry CASCADE;

-- Insert Master Engineers Registry Records
INSERT INTO engineers_registry (
    engineer_id, 
    full_name, 
    discipline, 
    role_qualification, 
    rank, 
    fund_status, 
    is_active
) VALUES
-- =========================================================================
-- AL-HASAKAH OFFICE (وحدة الحسكة)
-- =========================================================================
('ENG-HAS-CIV-0001', 'ابراهيم نجيم طاهر', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'OU', TRUE),
('ENG-HAS-CIV-0002', 'هيفي عابد احمد', 'CIV', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-HAS-CIV-0003', 'عبد الباقي داود احمد', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'OU', TRUE),
('ENG-HAS-CIV-0004', 'كاوا احمد صالح', 'CIV', 'دراسة', 'متدرب', 'OU', TRUE),
('ENG-HAS-CIV-0005', 'صالح نايف ابراهيم', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-CIV-0006', 'عبود فرحان العمر', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-CIV-0007', 'رقيه مجيد الحاج علي', 'CIV', 'دراسة', 'متدرب', 'OU', TRUE),
('ENG-HAS-CIV-0008', 'عبد الباسط نذير يوسف', 'CIV', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-HAS-CIV-0010', 'محمد مجول ياسين', 'CIV', 'دراسة', 'متدرب', 'OU', TRUE),
('ENG-HAS-CIV-0014', 'رشا فخري يونس', 'CIV', 'دراسة', 'متدرب', 'IN', TRUE),
('ENG-HAS-CIV-0019', 'هيفيدار محمد باقي محمد', 'CIV', 'دراسة', 'مشارك', 'IN', TRUE),
('ENG-HAS-CIV-0020', 'عبد العزيز عامر شيخي', 'CIV', 'دراسة', 'مشارك', 'IN', TRUE),
('ENG-HAS-CIV-0023', 'عامر محي الحيجي', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'OU', TRUE),

-- Soil Specialists (HAS)
('ENG-HAS-GTK-0043', 'زياد طارق بوش', 'GTK', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-GTK-0044', 'وليد عباس ججو', 'GTK', 'دراسة,تدريب,تدقيق', 'استشاري', 'OU', TRUE),
('ENG-HAS-GTK-0045', 'هبون عدنان الاحمد', 'GTK', 'دراسة', 'متدرب', 'OU', TRUE),

-- Architecture (HAS)
('ENG-HAS-ARC-0046', 'ابراهيم شيخموس حسين', 'ARC', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-HAS-ARC-0047', 'محمد مصلح عبد العزيز محمود', 'ARC', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-ARC-0048', 'عبد الحليم صبري ابراهيم', 'ARC', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-ARC-0049', 'دلال حسن النعمه', 'ARC', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-HAS-ARC-0051', 'زيندان علي محمد', 'ARC', 'دراسة', 'مشارك', 'OU', TRUE),

-- Mechanical (HAS)
('ENG-HAS-MCH-0060', 'ذاكرة محمد ولو', 'MCH', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-MCH-0061', 'محمد خضر يوسف', 'MCH', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-MCH-0065', 'عبد الرزاق خليل خليف', 'MCH', 'دراسة', 'متدرب', 'OU', TRUE),

-- Electrical (HAS)
('ENG-HAS-ELE-0066', 'عبد الرحمن محمد ولو', 'ELE', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-HAS-ELE-0067', 'محمد بشير سمعو ملا احمد', 'ELE', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-ELE-0068', 'عبد الحميد محمد ولو', 'ELE', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),

-- =========================================================================
-- QAMISHLI OFFICE (وحدة القامشلي)
-- =========================================================================
-- Civil & Water (QAM)
('ENG-QAM-CIV-0001', 'خالد يونس عجو', 'CIV', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-QAM-CIV-0004', 'جفين يوسف شيخموس', 'CIV', 'دراسة', 'تحت الاشراف', 'OU', TRUE),
('ENG-QAM-WTR-0001', 'آلا محمد بشار حبو', 'WTR', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-QAM-GEO-0005', 'احمد عبدالله العوض', 'GEO', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-QAM-GTK-0001', 'نسرين خلف خلف', 'GTK', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),

-- Architecture (QAM)
('ENG-QAM-ARC-0001', 'زليخان شوكت علي', 'ARC', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-QAM-ARC-0002', 'عمر يونس سليفي', 'ARC', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-QAM-ARC-0007', 'سامر شيخموس واوي', 'ARC', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-QAM-ARC-0034', 'فيريل يوسف توكمه جي', 'ARC', 'دراسة', 'تحت الاشراف', 'IN', TRUE),
('ENG-QAM-ARC-0039', 'هيفين بدر الدين إسماعيل', 'ARC', 'دراسة', 'متدرب', 'OU', TRUE),

-- Electrical & Mechanical (QAM)
('ENG-QAM-ELE-0001', 'اكرم احمد محمود', 'ELE', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-QAM-ELE-0022', 'هيم زكي سعدو', 'ELE', 'دراسة', 'تحت الاشراف', 'IN', TRUE),
('ENG-QAM-MCH-0001', 'إبراهيم مجيد شيخموس', 'MCH', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-QAM-MCH-0003', 'سعيد محمود عمر حسن', 'MCH', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),

-- =========================================================================
-- DERIK OFFICE (وحدة ديريك)
-- =========================================================================
-- Civil & Soils (DER)
('ENG-DER-CIV-0001', 'رمضان حسن', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'OU', TRUE),
('ENG-DER-CIV-0003', 'فرحان أحمد حسين', 'CIV', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-DER-CIV-0004', 'شيرزاد علوان إبراهيم', 'CIV', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-DER-CIV-0009', 'ليلى زبير عبدالله', 'CIV', 'دراسة', 'متدرب', 'OU', TRUE),
('ENG-DER-CIV-0010', 'نور إبراهيم يوسف', 'CIV', 'دراسة', 'متدرب', 'IN', TRUE),
('ENG-DER-GTK-0001', 'صالح محمد الرحيل', 'GTK', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-DER-GTK-0002', 'فنر عبدالباقي إبراهيم', 'GTK', 'دراسة', 'متدرب', 'OU', TRUE),

-- Architecture (DER)
('ENG-DER-ARC-0001', 'حسين علي خلف', 'ARC', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-DER-ARC-0002', 'حسن جتو', 'ARC', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-DER-ARC-0003', 'شيماء ياسر البرهو', 'ARC', 'دراسة', 'متدرب', 'IN', TRUE),
('ENG-DER-ARC-0005', 'دلفين عبد الفادر حاجي', 'ARC', 'دراسة', 'متدرب', 'OU', TRUE),

-- Electrical & Mechanical (DER)
('ENG-DER-ELE-0001', 'أحمد كورو جاجان', 'ELE', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-DER-ELE-0005', 'أرين جميل حمو', 'ELE', 'دراسة', 'متدرب', 'OU', TRUE),
('ENG-DER-MCH-0001', 'أحمد إسماعيل أحمد', 'MCH', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-DER-MCH-0004', 'عبد الباقي إبراهيم', 'MCH', 'دراسة,تدريب', 'ممارس', 'OU', TRUE);

COMMIT;
-- =========================================================================
-- END OF SEEDING SCRIPT
-- =========================================================================
