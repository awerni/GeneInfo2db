/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     02/06/2022 2:48:36 pm                        */
/*==============================================================*/


/*==============================================================*/
/* Table: FUSIONDESCRIPTION                                     */
/*==============================================================*/
create table FUSIONDESCRIPTION (
   PROCESSEDFUSION      INT4                 not null,
   FUSIONTYPE           TEXT                 not null,
   constraint PK_FUSIONDESCRIPTION primary key (PROCESSEDFUSION, FUSIONTYPE)
);

/*==============================================================*/
/* Table: HALLMARKSCORE                                         */
/*==============================================================*/
create table HALLMARKSCORE (
   GENE_SET             TEXT                 not null,
   TISSUENAME           TEXT                 not null,
   GSVA                 FLOAT4               null,
   SSGSEA               FLOAT4               null,
   constraint PK_HALLMARKSCORE primary key (TISSUENAME, GENE_SET)
);

/*==============================================================*/
/* Table: HLATYPE                                               */
/*==============================================================*/
create table HLATYPE (
   RNASEQRUNID          TEXT                 not null,
   HLA_CLASS            TEXT                 not null,
   ALLELE1              TEXT                 null,
   ALLELE2              TEXT                 null,
   constraint PK_HLATYPE primary key (RNASEQRUNID, HLA_CLASS)
);

/*==============================================================*/
/* Table: IMMUNECELLDECONVOLUTION                               */
/*==============================================================*/
create table IMMUNECELLDECONVOLUTION (
   TISSUENAME           TEXT                 not null,
   CELLTYPE             TEXT                 not null,
   SCORE                FLOAT4               null,
   constraint PK_IMMUNECELLDECONVOLUTION primary key (TISSUENAME, CELLTYPE)
);

/*==============================================================*/
/* Table: METABOLICS                                            */
/*==============================================================*/
create table METABOLICS (
   TISSUENAME           TEXT                 not null,
   METABOLIC_PATHWAY    TEXT                 not null,
   SCORE                FLOAT4               not null,
   constraint PK_METABOLICS primary key (TISSUENAME, METABOLIC_PATHWAY)
);

/*==============================================================*/
/* Table: PATIENT                                               */
/*==============================================================*/
create table PATIENT (
   PATIENTNAME          TEXT                 not null,
   VITAL_STATUS         BOOL                 null,
   DAYS_TO_BIRTH        INT4                 null,
   GENDER               TEXT                 null,
   HEIGHT               FLOAT4               null,
   WEIGHT               FLOAT4               null,
   RACE                 TEXT                 null,
   ETHNICITY            TEXT                 null,
   DAYS_TO_LAST_FOLLOWUP INT4                 null,
   DAYS_TO_LAST_KNOWN_ALIVE INT4                 null,
   DAYS_TO_DEATH        INT4                 null,
   PERSON_NEOPLASM_CANCER_STATUS TEXT                 null,
   DEATH_CLASSIFICATION TEXT                 null,
   TREATMENT            JSONB                null,
   constraint PK_PATIENT primary key (PATIENTNAME)
);

/*==============================================================*/
/* Table: PROCESSEDCOPYNUMBER                                   */
/*==============================================================*/
create table PROCESSEDCOPYNUMBER (
   TISSUENAME           TEXT                 not null,
   ENSG                 TEXT                 not null,
   LOG2RELATIVECOPYNUMBER FLOAT4               null,
   LOG2RELATIVECOPYNUMBERDEV FLOAT4               null,
   COPYNUMBERGAININTRON BOOL                 null,
   COPYNUMBERLOSSINTRON BOOL                 null,
   COPYNUMBERGAINEXON   BOOL                 null,
   COPYNUMBERLOSSEXON   BOOL                 null,
   GAP                  BOOL                 null,
   JUMP                 BOOL                 null,
   EXONICCHANGE         BOOL                 null,
   INTRONICCHANGE       BOOL                 null,
   COSMICDELETION       TEXT                 null,
   COSMICZYGOSITY       FLOAT4               null,
   CSDELETION           TEXT                 null,
   CSZYGOSITY           FLOAT4               null,
   NGSDELETION          TEXT                 null,
   NGSZYGOSITY          FLOAT4               null,
   SNPCHIPALTERATION    TEXT                 null,
   SNPCHIPZYGOSITY      FLOAT4               null,
   NUMSOURCES           INT2                 null,
   TOTALABSCOPYNUMBER   FLOAT4               null,
   TOTALABSCOPYNUMBERDEV FLOAT4               null,
   MINORABSCOPYNUMBER   FLOAT4               null,
   MINORABSCOPYNUMBERDEV FLOAT4               null,
   LOSSOFHETEROZYGOSITY BOOL                 null,
   constraint PK_PROCESSEDCOPYNUMBER primary key (TISSUENAME, ENSG)
);

/*==============================================================*/
/* Table: PROCESSEDFUSIONGENE                                   */
/*==============================================================*/
create table PROCESSEDFUSIONGENE (
   PROCESSEDFUSION      INT4                 not null,
   TISSUENAME           TEXT                 not null,
   ENSG1                TEXT                 not null,
   ENSG2                TEXT                 not null,
   COUNTSOFCOMMONMAPPINGREADS INT4                 null,
   SPANNINGPAIRS        INT4                 null,
   SPANNINGUNIQUEREADS  INT4                 null,
   LONGESTANCHORFOUND   INT4                 null,
   FUSIONFINDINGMETHOD  TEXT                 null,
   CHRGENE1             TEXT                 null,
   CHRGENE2             TEXT                 null,
   NUCLGENE1            INT4                 null,
   NUCLGENE2            INT4                 null,
   STRANDGENE1          CHAR                 null,
   STRANDGENE2          CHAR                 null,
   RNASEQRUNID          TEXT                 null,
   PREDICTEDEFFECT      TEXT                 null,
   constraint PK_PROCESSEDFUSIONGENE primary key (PROCESSEDFUSION)
);

/*==============================================================*/
/* Table: PROCESSEDPROTEINEXPRESSION                            */
/*==============================================================*/
create table PROCESSEDPROTEINEXPRESSION (
   TISSUENAME           TEXT                 not null,
   ANTIBODY             TEXT                 not null,
   SCORE                FLOAT4               null,
   constraint PK_PROCESSEDPROTEINEXPRESSION primary key (TISSUENAME, ANTIBODY)
);

/*==============================================================*/
/* Table: PROCESSEDRNASEQ                                       */
/*==============================================================*/
create table PROCESSEDRNASEQ (
   ENSG                 TEXT                 not null,
   RNASEQRUNID          TEXT                 not null,
   LOG2FPKM             REAL                 null,
   LOG2TPM              REAL                 null,
   LOG2CPM              REAL                 null,
   COUNTS               INT4                 null,
   constraint PK_PROCESSEDRNASEQ primary key (ENSG, RNASEQRUNID)
);

/*==============================================================*/
/* Table: PROCESSEDRNASEQTRANSCRIPT                             */
/*==============================================================*/
create table PROCESSEDRNASEQTRANSCRIPT (
   RNASEQRUNID          TEXT                 not null,
   ENST                 TEXT                 not null,
   LOG2FPKM             REAL                 null,
   LOG2TPM              REAL                 null,
   LOG2CPM              REAL                 null,
   COUNTS               INT4                 null,
   constraint PK_PROCESSEDRNASEQTRANSCRIPT primary key (ENST, RNASEQRUNID)
);

/*==============================================================*/
/* Table: PROCESSEDSEQUENCE                                     */
/*==============================================================*/
create table PROCESSEDSEQUENCE (
   TISSUENAME           TEXT                 not null,
   ENST                 TEXT                 not null,
   DNAMUTATION          TEXT                 null,
   DNAMUTATION_TRUNCATED TEXT                 null,
   AAMUTATION           TEXT                 null,
   AAMUTATION_TRUNCATED TEXT                 null,
   DNAZYGOSITY          FLOAT4               null,
   RNAZYGOSITY          FLOAT4               null,
   EXONSCOMPLETE        FLOAT4               null,
   constraint PK_PROCESSEDSEQUENCE primary key (TISSUENAME, ENST)
);

/*==============================================================*/
/* Table: RNASEQGROUP                                           */
/*==============================================================*/
create table RNASEQGROUP (
   RNASEQGROUPID        INT4                 not null,
   RNASEQNAME           TEXT                 null,
   RDATAFILEPATH        TEXT                 null,
   PROCESSINGPIPELINE   TEXT                 null,
   constraint PK_RNASEQGROUP primary key (RNASEQGROUPID)
);

/*==============================================================*/
/* Table: RNASEQRUN                                             */
/*==============================================================*/
create table RNASEQRUN (
   RNASEQRUNID          TEXT                 not null,
   TISSUENAME           TEXT                 not null,
   LABORATORY           TEXT                 null,
   RNASEQGROUPID        INT4                 null,
   ASSOCIATEDRNASEQRUNID TEXT                 null,
   CELLBATCHID          INT4                 null,
   DIRECTORY            TEXT                 null,
   ISXENOGRAFT          BOOL                 null,
   PUBLISH              BOOL                 null,
   COMMENT              TEXT                 null,
   CANONICAL            BOOL                 null,
   SOURCEID             TEXT                 null,
   constraint PK_RNASEQRUN primary key (RNASEQRUNID)
);

/*==============================================================*/
/* Table: SIGNALING_PATHWAY                                     */
/*==============================================================*/
create table SIGNALING_PATHWAY (
   TISSUENAME           TEXT                 not null,
   CELL_CYCLE           BOOL                 null,
   HIPPO                BOOL                 null,
   MYC                  BOOL                 null,
   NOTCH                BOOL                 null,
   NRF2                 BOOL                 null,
   PI3K                 BOOL                 null,
   RTK_RAS              BOOL                 null,
   TP53                 BOOL                 null,
   TGF_BETA             BOOL                 null,
   WNT                  BOOL                 null,
   constraint PK_SIGNALING_PATHWAY primary key (TISSUENAME)
);

/*==============================================================*/
/* Table: SIMILARITY                                            */
/*==============================================================*/
create table SIMILARITY (
   SIMILARITYID         INT4                 not null,
   TISSUENAME           TEXT                 not null,
   SIMILARITYTYPE       TEXT                 null,
   SOURCE               TEXT                 null,
   COMMENT              TEXT                 null,
   constraint PK_SIMILARITY primary key (SIMILARITYID, TISSUENAME)
);

/*==============================================================*/
/* Table: TISSUE                                                */
/*==============================================================*/
create table TISSUE (
   TISSUENAME           TEXT                 not null,
   VENDORNAME           TEXT                 not null,
   SPECIES              TEXT                 not null,
   ORGAN                TEXT                 null,
   TUMORTYPE            TEXT                 null,
   PATIENTNAME          TEXT                 null,
   TUMORTYPE_ADJACENT   TEXT                 null,
   TISSUE_SUBTYPE       TEXT                 null,
   METASTATIC_SITE      TEXT                 null,
   HISTOLOGY_TYPE       TEXT                 null,
   HISTOLOGY_SUBTYPE    TEXT                 null,
   AGE_AT_SURGERY       TEXT                 null,
   STAGE                TEXT                 null,
   GRADE                TEXT                 null,
   SAMPLE_DESCRIPTION   TEXT                 null,
   COMMENT              TEXT                 null,
   DNASEQUENCED         BOOL                 null,
   TUMORPURITY          FLOAT4               null,
   TDPID                SERIAL               not null,
   MICROSATELLITE_STABILITY_SCORE FLOAT4               null,
   MICROSATELLITE_STABILITY_CLASS TEXT                 null,
   IMMUNE_ENVIRONMENT   TEXT                 null,
   GI_MOL_SUBGROUP      TEXT                 null,
   ICLUSTER             TEXT                 null,
   TIL_PATTERN          TEXT                 null,
   NUMBER_OF_CLONES     FLOAT4               null,
   CLONE_TREE_SCORE     FLOAT4               null,
   RNA_INTEGRITY_NUMBER FLOAT4               null,
   MINUTES_ISCHEMIA     INT4                 null,
   AUTOLYSIS_SCORE      TEXT                 null,
   CONSMOLSUBTYPE       TEXT                 null,
   LOSSOFY              BOOL                 null,
   constraint PK_TISSUE primary key (TISSUENAME)
);

/*==============================================================*/
/* Table: TISSUE2GENESIGNATURE                                  */
/*==============================================================*/
create table TISSUE2GENESIGNATURE (
   TISSUENAME           TEXT                 not null,
   SIGNATURE            TEXT                 not null,
   SCORE                REAL                 not null,
   constraint PK_TISSUE2GENESIGNATURE primary key (TISSUENAME, SIGNATURE)
);

/*==============================================================*/
/* Table: TISSUEASSIGNMENT                                      */
/*==============================================================*/
create table TISSUEASSIGNMENT (
   TISSUEPANEL          TEXT                 not null,
   TISSUENAME           TEXT                 not null,
   constraint PK_TISSUEASSIGNMENT primary key (TISSUEPANEL, TISSUENAME)
);

/*==============================================================*/
/* Table: TISSUEPANEL                                           */
/*==============================================================*/
create table TISSUEPANEL (
   TISSUEPANEL          TEXT                 not null,
   TISSUEPANELDESCRIPTION TEXT                 null,
   SPECIES              TEXT                 null,
   constraint PK_TISSUEPANEL primary key (TISSUEPANEL)
);

/*==============================================================*/
/* Table: TUMORTYPE                                             */
/*==============================================================*/
create table TUMORTYPE (
   TUMORTYPE            TEXT                 not null,
   TUMORTYPEDESC        TEXT                 null,
   constraint PK_TUMORTYPE primary key (TUMORTYPE)
);

/*==============================================================*/
/* Table: VENDOR                                                */
/*==============================================================*/
create table VENDOR (
   VENDORNAME           TEXT                 not null,
   VENDORURL            TEXT                 null,
   constraint PK_VENDOR primary key (VENDORNAME)
);

alter table FUSIONDESCRIPTION
   add constraint FK_FUSIONDE_REFERENCE_PROCESSE foreign key (PROCESSEDFUSION)
      references PROCESSEDFUSIONGENE (PROCESSEDFUSION)
      on delete restrict on update restrict;

alter table FUSIONDESCRIPTION
   add constraint FK_FUSIONDE_REFERENCE_FUSIONTY foreign key (FUSIONTYPE)
      references FUSIONTYPE (FUSIONTYPE)
      on delete restrict on update restrict;

alter table HALLMARKSCORE
   add constraint FK_HALLMARK_REFERENCE_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete restrict on update restrict;

alter table HLATYPE
   add constraint FK_HLATYPE_REFERENCE_RNASEQRU foreign key (RNASEQRUNID)
      references RNASEQRUN (RNASEQRUNID)
      on delete cascade on update restrict;

alter table IMMUNECELLDECONVOLUTION
   add constraint FK_IMMUNECE_REFERENCE_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete restrict on update restrict;

alter table METABOLICS
   add constraint FK_METABOLI_REFERENCE_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete restrict on update restrict;

alter table PROCESSEDCOPYNUMBER
   add constraint FK_PROCCN_2_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete restrict on update restrict;

alter table PROCESSEDCOPYNUMBER
   add constraint FK_PROCESSECN_2_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table PROCESSEDFUSIONGENE
   add constraint FK_PROCESSEDFUSION_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete restrict on update restrict;

alter table PROCESSEDFUSIONGENE
   add constraint FK_PROCESSEFUSEION_ENSG1 foreign key (ENSG1)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table PROCESSEDFUSIONGENE
   add constraint FK_PROCESSEFUSEION_ENSG2 foreign key (ENSG2)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table PROCESSEDPROTEINEXPRESSION
   add constraint FK_PROCESSED_PROT_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete restrict on update restrict;

alter table PROCESSEDPROTEINEXPRESSION
   add constraint FK_PROCESSE_REFERENCE_ANTIBODY foreign key (ANTIBODY)
      references ANTIBODY (ANTIBODY)
      on delete restrict on update restrict;

alter table PROCESSEDRNASEQ
   add constraint FK_PROCESSERNAS2GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table PROCESSEDRNASEQ
   add constraint FK_PROCESSE_RNASEQRUN foreign key (RNASEQRUNID)
      references RNASEQRUN (RNASEQRUNID)
      on delete cascade on update cascade;

alter table PROCESSEDRNASEQTRANSCRIPT
   add constraint FK_PROCESSE_REFERENCE_TRANSCRI foreign key (ENST)
      references TRANSCRIPT (ENST)
      on delete restrict on update restrict;

alter table PROCESSEDRNASEQTRANSCRIPT
   add constraint FK_PROCESS_RNASEQRUN_TRANSCRIPT foreign key (RNASEQRUNID)
      references RNASEQRUN (RNASEQRUNID)
      on delete cascade on update cascade;

alter table PROCESSEDSEQUENCE
   add constraint FK_PROCESSED_2_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete restrict on update restrict;

alter table PROCESSEDSEQUENCE
   add constraint FK_PROCESSESeq_TRANSCRIpt foreign key (ENST)
      references TRANSCRIPT (ENST)
      on delete restrict on update restrict;

alter table RNASEQRUN
   add constraint FK_RNASEQRU_REFERENCE_RNASEQGR foreign key (RNASEQGROUPID)
      references RNASEQGROUP (RNASEQGROUPID)
      on delete restrict on update restrict;

alter table RNASEQRUN
   add constraint FK_RNASEQRU_REFERENCE_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete cascade on update cascade;

alter table RNASEQRUN
   add constraint FK_RNASEQRU_REFERENCE_LABORATO foreign key (LABORATORY)
      references LABORATORY (LABORATORY)
      on delete restrict on update restrict;

alter table RNASEQRUN
   add constraint FK_RNASEQRU_REFERENCE_RNASEQRU foreign key (ASSOCIATEDRNASEQRUNID)
      references RNASEQRUN (RNASEQRUNID)
      on delete cascade on update cascade;

alter table SIGNALING_PATHWAY
   add constraint FK_SIGNALIN_REFERENCE_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete cascade on update cascade;

alter table SIMILARITY
   add constraint FK_SIMILARI_REFERENCE_SIMILARI foreign key (SIMILARITYTYPE)
      references SIMILARITYTYPE (SIMILARITYTYPE)
      on delete cascade on update cascade;

alter table SIMILARITY
   add constraint FK_SIMILARI_REFERENCE_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete restrict on update restrict;

alter table TISSUE
   add constraint FK_TISSUE_REFERENCE_VENDOR foreign key (VENDORNAME)
      references VENDOR (VENDORNAME)
      on delete restrict on update restrict;

alter table TISSUE
   add constraint FK_TISSUE_REFERENCE_TUMORTYP foreign key (TUMORTYPE)
      references TUMORTYPE (TUMORTYPE)
      on delete restrict on update restrict;

alter table TISSUE
   add constraint FK_TISSUE_REFERENCE_PATIENT foreign key (PATIENTNAME)
      references PATIENT (PATIENTNAME)
      on delete restrict on update restrict;

alter table TISSUE
   add constraint FK_TISSUE_TUMORTYPEADJACENT foreign key (TUMORTYPE_ADJACENT)
      references TUMORTYPE (TUMORTYPE)
      on delete restrict on update restrict;

alter table TISSUE2GENESIGNATURE
   add constraint FK_TISSUE2G_REFERENCE_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete cascade on update cascade;

alter table TISSUE2GENESIGNATURE
   add constraint FK_TISSUE2G_REFERENCE_GENESIGN foreign key (SIGNATURE)
      references GENESIGNATURE (SIGNATURE)
      on delete cascade on update cascade;

alter table TISSUEASSIGNMENT
   add constraint FK_TISSUEAS_REFERENCE_TISSUE foreign key (TISSUENAME)
      references TISSUE (TISSUENAME)
      on delete restrict on update restrict;

alter table TISSUEASSIGNMENT
   add constraint FK_TISSUEAS_REFERENCE_TISSUEPA foreign key (TISSUEPANEL)
      references TISSUEPANEL (TISSUEPANEL)
      on delete restrict on update restrict;

