INSERT INTO cellline.alternative_celllinename SELECT celllinename, depmap AS alternative_celllinename, 'depmapID' AS source FROM cellline.cellline WHERE depmap is not null;
INSERT INTO cellline.alternative_celllinename SELECT celllinename, cellosaurus AS alternative_celllinename, 'cellosaurus' AS source FROM cellline.cellline WHERE cellosaurus is not null;
INSERT INTO cellline.alternative_celllinename SELECT celllinename, cell_model_passport AS alternative_celllinename, 'cell_model_passport' AS source FROM cellline.cellline WHERE cell_model_passport is not null;

INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('BC3_PLEURA','BC-3', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('BE2M17_AUTONOMIC_GANGLIA','BE(2)-M17', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('CORL105_LUNG','COR-L 105', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('CORL321_LUNG','COR-L321', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('G292CLONEA141B1_BONE','G-292 Clone A141B1', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('GMEL_SKIN','G-MEL', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HCET_UPPER_AERODIGESTIVE_TRACT','HCE-T', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HEY_OVARY','Hey', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HS633T_SOFT_TISSUE','Hs 633T', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HT1080_SOFT_TISSUE','HT 1080', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HT1376_URINARY_TRACT','HT 1376', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('KMH2_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE','KM-H2', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('KMH2_THYROID','KMH-2', 'Amgen');
--INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('KMS12PE_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE','KMS-12-PE', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('KYSE220_OESOPHAGUS','KYSE-220', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('KYSE50_OESOPHAGUS','KYSE-50', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('M14_SKIN','M-14', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('MOT_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE','Mo-T', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2052_PLEURA','H2052', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH28_PLEURA','H28', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH292_LUNG','H292', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('OACM51_OESOPHAGUS','OACM5-1', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('OACP4C_OESOPHAGUS','OACp4C', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('OV17R_OVARY','OV-17R', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('PC3JPC3_LUNG','PC-3 [JPC-3]', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('RF48_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE','RF-48', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SN12C_KIDNEY','SN-12C', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW1116_LARGE_INTESTINE','SW 1116', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW13_ADRENAL_CORTEX','SW 13', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW1417_LARGE_INTESTINE','SW 1417', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW1463_LARGE_INTESTINE','SW 1463', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW48_LARGE_INTESTINE','SW 48', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW948_LARGE_INTESTINE','SW-948', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('TT_OESOPHAGUS','T.T', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('UO31_KIDNEY','UO-31', 'Amgen');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('WIL2NS_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE','WIL2 NS', 'Amgen');


INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('A101D_SKIN', 'A101D', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('A172_CENTRAL_NERVOUS_SYSTEM', 'A-172', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('A427_LUNG', 'A-427', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('A431_SKIN', 'A-431', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('BICR10_UPPER_AERODIGESTIVE_TRACT', 'BICR 10', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('BICR78_UPPER_AERODIGESTIVE_TRACT', 'BICR 78', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('BLUE1_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'BLUE-1', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('C33A_CERVIX', 'C-33 A', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('C4I_CERVIX', 'C-4 I', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('CASKI_CERVIX', 'Ca Ski', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('CHL1_SKIN', 'CHL-1', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('COLO320HSR_LARGE_INTESTINE', 'COLO 320HSR', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('CS1_BONE', 'CS-1', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('DOTC24510_CERVIX', 'DoTc2 4510', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('ESO26_OESOPHAGUS', 'ESO-26', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('ESO51_OESOPHAGUS', 'ESO-51', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('GMEL_SKIN', 'G-mel', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('GRM_SKIN', 'GR-M', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HARA_LUNG', 'HARA_lung', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HCC2429_LUNG', 'HCC-2429', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HCC2998_LARGE_INTESTINE', 'HCC-2998', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HCC461_LUNG', 'HCC-461', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HCC515_LUNG', 'HCC-515', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HCC827GR5_LUNG', 'HCC-827-GR5', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HELA_CERVIX', 'HeLa S3', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HMCB_SKIN', 'HMCB', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HS445_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'Hs 445', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HS633T_SOFT_TISSUE', 'Hs 633.T', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HTCC3_THYROID', 'HTC/C3', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('JIYOYEP2003_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'Jiyoye', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('JOPACA1_PANCREAS', 'JOPACA-1', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('KARPAS231_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'Karpas-231', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('KARPAS299_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'Karpas-299', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('KE97_STOMACH', 'KE-97', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('LAN2_AUTONOMIC_GANGLIA', 'LAN-2', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('LC1F_LUNG', 'LC-1F', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('LC1SQ_LUNG', 'LC-1/sq', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('LC1SQSF_LUNG', 'LC-1/sq-SF', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('LC2AD_LUNG', 'LC-2/ad', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('LNCAPCLONEFGC_PROSTATE', 'LNCap.FGC', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('LU134A_LUNG', 'Lu-134-A', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('LU135_LUNG', 'Lu-135', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('LU139_LUNG', 'Lu-139', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('LU165_LUNG', 'Lu-165', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('MCCAR_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'MC/CAR', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('MCF10A_BREAST', 'MCF 10A', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('MM1S_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'MM.1S', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('MS1_LUNG', 'MS-1', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('MS1_SKIN', 'MS-1', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH1581_LUNG', 'NCI-H1581', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2077_LUNG', 'NCI-H2077', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('H2369_PLEURA', 'NCI-H2369', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2373_PLEURA', 'NCI-H2373', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2461_PLEURA', 'NCI-H2461', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2591_PLEURA', 'NCI-H2591', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2595_PLEURA', 'NCI-H2595', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2722_PLEURA', 'NCI-H2722', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2731_PLEURA', 'NCI-H2731', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2795_PLEURA', 'NCI-H2795', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2803_PLEURA', 'NCI-H2803', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2804_PLEURA', 'NCI-H2804', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2810_PLEURA', 'NCI-H2810', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2818_PLEURA', 'NCI-H2818', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH2869_PLEURA', 'NCI-H2869', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('H290_PLEURA', 'NCI-H290', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('H3118_UPPER_AERODIGESTIVE_TRACT', 'NCI-H3118', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('H513_LUNG', 'NCI-H513', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NCIH630_LARGE_INTESTINE', 'NCI-H630', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NO10_CENTRAL_NERVOUS_SYSTEM', 'no.10', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NO11_CENTRAL_NERVOUS_SYSTEM', 'no.11', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('NTERA2CLD1_TESTIS', 'NTERA-2 cl.D1', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('OACM51_OESOPHAGUS', 'OAC-M5.1', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('OACP4C_OESOPHAGUS', 'OAC-P4C', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('OCILY7_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'OCI-Ly7', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('P30OHK_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'P30/OHK', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('P32ISH_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'P32/ISH', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('PACADD119_PANCREAS', 'PACADD-119', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('PACADD137_PANCREAS', 'PACADD-137', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('PACADD165_PANCREAS', 'PACADD-165', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('PC3JPC3_LUNG', 'PC-3_lung', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('PSN1_PANCREAS', 'PSN-1', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('RAMOS2G64C10_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'Ramos.2G6.4C10', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('RH30_SOFT_TISSUE', 'RH-30', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('RPMI2650_UPPER_AERODIGESTIVE_TRACT', 'RPMI 2650', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('RXF393_KIDNEY', 'RXF-393', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SET2_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'SET-2', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SF268_CENTRAL_NERVOUS_SYSTEM', 'SF-268', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SF539_CENTRAL_NERVOUS_SYSTEM', 'SF-539', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SNB75_CENTRAL_NERVOUS_SYSTEM', 'SNB-75', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW13_ADRENAL_CORTEX', 'SW-13', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW156_KIDNEY', 'SW 156', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW626_LARGE_INTESTINE', 'SW 626', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW684_SOFT_TISSUE', 'SW 684', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW872_SOFT_TISSUE', 'SW 872', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW954_CERVIX', 'SW 954', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SW982_SOFT_TISSUE', 'SW 982', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('TK10_KIDNEY', 'TK-10', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('TT_OESOPHAGUS', 'T.T_eso', 'BI');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('CACO2_LARGE_INTESTINE', 'Caco2', 'Paper');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HELA_CERVIX', 'HeLaS3', 'Paper');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('HEPG2_LIVER', 'HepG2', 'Paper');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('JURKAT_HAEMATOPOIETIC_AND_LYMPHOID_TISSUE', 'Jurkat E6.1', 'Paper');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('LNCAPCLONEFGC_PROSTATE', 'LNCaP', 'Paper');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('MIAPACA2_PANCREAS', 'MiaPaca-2', 'Paper');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('PANC0813_PANCREAS', 'Panc-08-13', 'Paper');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('PANC1_PANCREAS', 'Panc-1', 'Paper');
INSERT INTO cellline.alternative_celllinename (celllinename, alternative_celllinename, source) VALUES ('SUIT2_PANCREAS', 'Suit-2', 'Paper');
