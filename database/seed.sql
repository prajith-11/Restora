-- Seed Data: ACL Reconstruction Target Recovery Milestones
-- Maps out expectations for Week 1 through Week 4 (Days 1 to 28)

INSERT INTO baseline_curves (surgery_type, days_since_surgery, target_pain_score, target_flexion_degrees) VALUES
-- Week 1: Manage acute pain, focus on full extension (0 degrees)
('ACL_RECONSTRUCTION', 1,  8, 0),
('ACL_RECONSTRUCTION', 2,  7, 5),
('ACL_RECONSTRUCTION', 3,  7, 10),
('ACL_RECONSTRUCTION', 4,  6, 15),
('ACL_RECONSTRUCTION', 5,  6, 20),
('ACL_RECONSTRUCTION', 6,  5, 30),
('ACL_RECONSTRUCTION', 7,  5, 45), -- Target: 45° flexion by end of week 1

-- Week 2: Swelling goes down, begin moving toward 90 degrees
('ACL_RECONSTRUCTION', 8,  5, 50),
('ACL_RECONSTRUCTION', 9,  4, 55),
('ACL_RECONSTRUCTION', 10, 4, 60),
('ACL_RECONSTRUCTION', 11, 4, 65),
('ACL_RECONSTRUCTION', 12, 4, 70),
('ACL_RECONSTRUCTION', 13, 3, 80),
('ACL_RECONSTRUCTION', 14, 3, 90), -- Target: 90° flexion by day 14

-- Weeks 3 & 4: Weaning off crutches, pushing past 90 toward full mobility
('ACL_RECONSTRUCTION', 21, 2, 105), -- Target: 105° flexion by day 21
('ACL_RECONSTRUCTION', 28, 1, 120); -- Target: 120° flexion by day 28