DELETE FROM tissue.tissueassignment WHERE tissuepanel = 'GTEx normals';
DELETE FROM tissue.tissueassignment WHERE tissuepanel = 'TCGA normals';
DELETE FROM tissue.tissueassignment WHERE tissuepanel = 'TCGA tumors';
DELETE FROM tissue.tissueassignment WHERE tissuepanel = 'TCGA and GTEx';
DELETE FROM tissue.tissueassignment WHERE tissuepanel = 'PDX Models';

DELETE FROM tissue.tissuepanel WHERE tissuepanel = 'GTEx normals';
DELETE FROM tissue.tissuepanel WHERE tissuepanel = 'TCGA normals';
DELETE FROM tissue.tissuepanel WHERE tissuepanel = 'TCGA tumors';
DELETE FROM tissue.tissuepanel WHERE tissuepanel = 'TCGA and GTEx';
DELETE FROM tissue.tissuepanel WHERE tissuepanel = 'PDX Models';

INSERT INTO tissue.tissuepanel VALUES ('GTEx normals', 'The whole panel of GTEx samples', 'human');
INSERT INTO tissue.tissuepanel VALUES ('TCGA normals', 'Near normal TCGA samples', 'human');
INSERT INTO tissue.tissuepanel VALUES ('TCGA tumors', 'TCGA tumor samples', 'human');
--INSERT INTO tissue.tissuepanel VALUES ('PDX Models', 'Patient Derived Xenograft models from CROs', 'human');

INSERT INTO tissue.tissueassignment(tissuepanel, tissuename) SELECT 'TCGA normals', tissuename FROM tissue.tissue WHERE tissuename like 'TCGA%' AND right(tissuename, 2)::INT2 >= 10;
INSERT INTO tissue.tissueassignment(tissuepanel, tissuename) SELECT 'TCGA tumors', tissuename FROM tissue.tissue WHERE tissuename like 'TCGA%' AND right(tissuename, 2)::INT2 < 10;
INSERT INTO tissue.tissueassignment(tissuepanel, tissuename) SELECT 'GTEx normals', tissuename FROM tissue.tissue WHERE tissuename like 'GTEX%';

INSERT INTO tissue.tissuepanel (tissuepanel, tissuepaneldescription, species) VALUES ('TCGA and GTEx', 'TCGA tumors, adjacent normal, and complementing GTEx normals', 'human');
INSERT INTO tissue.tissueassignment(tissuepanel, tissuename) SELECT 'TCGA and GTEx', tissuename FROM tissue.tissue WHERE tissuename like 'TCGA%';
INSERT INTO tissue.tissueassignment(tissuepanel, tissuename) SELECT 'TCGA and GTEx', tissuename FROM tissue.tissue WHERE tissuename like 'GTEX%';

--INSERT INTO tissue.tissueassignment(tissuepanel, tissuename) SELECT 'PDX Models', tissuename FROM tissue.tissue WHERE vendorname IN ('Crown Bioscience', 'MD Anderson Cancer Center',
-- 'Oncodesign', 'Jackson Laboratory', 'Experimental Pharmacology & Oncology Berlin-Buch GmbH (EPO)', 'Champions Oncology', 'OncoTrack', 'Oncotest', 'Eva Corey (University of Washington)',
--'WuXi AppTec');