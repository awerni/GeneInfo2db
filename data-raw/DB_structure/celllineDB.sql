/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     28/02/2022 3:01:47 pm                        */
/*==============================================================*/


/*==============================================================*/
/* Table: ALTERNATIVE_CELLLINENAME                              */
/*==============================================================*/
create table ALTERNATIVE_CELLLINENAME (
   CELLLINENAME         TEXT                 not null,
   ALTERNATIVE_CELLLINENAME TEXT                 not null,
   SOURCE               TEXT                 not null,
   constraint PK_ALTERNATIVE_CELLLINENAME primary key (CELLLINENAME, ALTERNATIVE_CELLLINENAME, SOURCE)
);

/*==============================================================*/
/* Table: CAMPAIGN                                              */
/*==============================================================*/
create table CAMPAIGN (
   CAMPAIGN             TEXT                 not null,
   CAMPAIGNDESC         TEXT                 null,
   DIRECTORY            TEXT                 null,
   constraint PK_CAMPAIGN primary key (CAMPAIGN)
);

/*==============================================================*/
/* Table: CELLLINE                                              */
/*==============================================================*/
create table CELLLINE (
   CELLLINENAME         TEXT                 not null,
   SPECIES              TEXT                 not null,
   ORGAN                TEXT                 null,
   TISSUE_SUBTYPE       TEXT                 null,
   METASTATIC_SITE      TEXT                 null,
   HISTOLOGY_TYPE       TEXT                 null,
   HISTOLOGY_SUBTYPE    TEXT                 null,
   MORPHOLOGY           TEXT                 null,
   TUMORTYPE            TEXT                 null,
   GROWTH_TYPE          TEXT                 null,
   GENDER               TEXT                 null,
   PLOIDY               TEXT                 null,
   AGE_AT_SURGERY       TEXT                 null,
   STAGE                TEXT                 null,
   GRADE                TEXT                 null,
   ATCC_NO              TEXT                 null,
   DSMZ_NO              TEXT                 null,
   ECACC_NO             TEXT                 null,
   JCRB_NO              TEXT                 null,
   ICLC_NO              TEXT                 null,
   RIKEN_NO             TEXT                 null,
   KCLB_NO              TEXT                 null,
   COSMICID             INT4                 null,
   PUBMED               INT4                 null,
   CELLOSAURUS          TEXT                 null,
   DEPMAP               TEXT                 null,
   CELL_MODEL_PASSPORT  TEXT                 null,
   CCLE                 TEXT                 null,
   COMMENT              TEXT                 null,
   PUBLIC               BOOL                 null,
   TDPID                SERIAL               not null,
   LOSSOFY              BOOL                 null,
   constraint PK_CELLLINE primary key (CELLLINENAME)
);

/*==============================================================*/
/* Table: CELLLINE2GENESIGNATURE                                */
/*==============================================================*/
create table CELLLINE2GENESIGNATURE (
   CELLLINENAME         TEXT                 not null,
   SIGNATURE            TEXT                 not null,
   SCORE                REAL                 not null,
   constraint PK_CELLLINE2GENESIGNATURE primary key (CELLLINENAME, SIGNATURE)
);

/*==============================================================*/
/* Table: CELLLINEASSIGNMENT                                    */
/*==============================================================*/
create table CELLLINEASSIGNMENT (
   CELLLINENAME         TEXT                 not null,
   CELLLINEPANEL        TEXT                 not null,
   constraint PK_CELLLINEASSIGNMENT primary key (CELLLINENAME, CELLLINEPANEL)
);

/*==============================================================*/
/* Table: CELLLINEPANEL                                         */
/*==============================================================*/
create table CELLLINEPANEL (
   CELLLINEPANEL        TEXT                 not null,
   CELLLINEPANELDESCRIPTION TEXT                 null,
   SPECIES              TEXT                 null,
   constraint PK_CELLLINEPANEL primary key (CELLLINEPANEL)
);

/*==============================================================*/
/* Table: DEPLETIONSCREEN                                       */
/*==============================================================*/
create table DEPLETIONSCREEN (
   DEPLETIONSCREEN      TEXT                 not null,
   DEPLETIONSCREENDESCRIPTION TEXT                 null,
   constraint PK_DEPLETIONSCREEN primary key (DEPLETIONSCREEN)
);

/*==============================================================*/
/* Table: DNASEQRUN                                             */
/*==============================================================*/
create table DNASEQRUN (
   DNASEQRUNID          INT4                 not null,
   CELLLINENAME         TEXT                 not null,
   CELLBATCHID          INT4                 null,
   PUBMEDID             INT4                 null,
   COMMENT              TEXT                 null,
   VCF_FILEID           TEXT                 null,
   ANALYSISSOURCE       TEXT                 null,
   PUBLISH              BOOL                 not null,
   constraint PK_DNASEQRUN primary key (DNASEQRUNID)
);

/*==============================================================*/
/* Table: FUSIONDESCRIPTION                                     */
/*==============================================================*/
create table FUSIONDESCRIPTION (
   PROCESSEDFUSION      INT4                 not null,
   FUSIONTYPE           TEXT                 not null,
   constraint PK_FUSIONDESCRIPTION primary key (PROCESSEDFUSION, FUSIONTYPE)
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
/* Table: METABOLITE                                            */
/*==============================================================*/
create table METABOLITE (
   METABOLITE           TEXT                 not null,
   constraint PK_METABOLITE primary key (METABOLITE)
);

/*==============================================================*/
/* Table: METMAP                                                */
/*==============================================================*/
create table METMAP (
   CELLLINENAME         TEXT                 not null,
   ORGAN                TEXT                 not null,
   MET_POTENTIAL        FLOAT4               not null,
   CI5PERCENT           FLOAT4               null,
   CI95PERCENT          FLOAT4               null,
   PENETRANCE           FLOAT4               not null,
   constraint PK_METMAP primary key (CELLLINENAME, ORGAN)
);

/*==============================================================*/
/* Table: MICROSATELLITEINSTABILITY                             */
/*==============================================================*/
create table MICROSATELLITEINSTABILITY (
   DNASEQRUNID          INT4                 not null,
   MICROSATELLITE_STABILITY_SCORE FLOAT4               null,
   MICROSATELLITE_STABILITY_CLASS TEXT                 null,
   TOTAL_NUMBER_OF_SITES INT4                 null,
   constraint PK_MICROSATELLITEINSTABILITY primary key (DNASEQRUNID)
);

/*==============================================================*/
/* Table: MUTATIONAL_SIGNATURE                                  */
/*==============================================================*/
create table MUTATIONAL_SIGNATURE (
   MUTATIONAL_SIGNATURE TEXT                 not null,
   MUTATIONAL_SIGNATURE_DESC TEXT                 null,
   constraint PK_MUTATIONAL_SIGNATURE primary key (MUTATIONAL_SIGNATURE)
);

/*==============================================================*/
/* Table: MUTATIONAL_SIGNATURE_PROFILE                          */
/*==============================================================*/
create table MUTATIONAL_SIGNATURE_PROFILE (
   CELLLINENAME         TEXT                 not null,
   MUTATIONAL_SIGNATURE TEXT                 not null,
   FREQ_ESTIMATION      INT2                 null,
   ACTIVITY             FLOAT4               null,
   constraint PK_MUTATIONAL_SIGNATURE_PROFIL primary key (CELLLINENAME, MUTATIONAL_SIGNATURE)
);

/*==============================================================*/
/* Table: PROCESSEDCOMBIPROLIFTEST                              */
/*==============================================================*/
create table PROCESSEDCOMBIPROLIFTEST (
   COMBIPROLIFTESTID    INT4                 not null,
   CELLLINENAME         TEXT                 null,
   DRUGID1              TEXT                 null,
   DRUGID2              TEXT                 null,
   CAMPAIGN             TEXT                 null,
   LABORATORY           TEXT                 null,
   PROLIFERATIONTEST    TEXT                 null,
   TIMEPOINT_IN_HOURS   INT4                 null,
   TZERO                FLOAT4               null,
   COMBO6               FLOAT4               null,
   CSCORE               FLOAT4               null,
   SYNERGY_SCORE        FLOAT4               null,
   constraint PK_PROCESSEDCOMBIPROLIFTEST primary key (COMBIPROLIFTESTID)
);

/*==============================================================*/
/* Table: PROCESSEDCOPYNUMBER                                   */
/*==============================================================*/
create table PROCESSEDCOPYNUMBER (
   CELLLINENAME         TEXT                 not null,
   ENSG                 TEXT                 not null,
   LOG2RELATIVECOPYNUMBER FLOAT4               null,
   TOTALABSCOPYNUMBER   FLOAT4               null,
   LOSSOFHETEROZYGOSITY BOOL                 null,
   constraint PK_PROCESSEDCOPYNUMBER primary key (CELLLINENAME, ENSG)
);

/*==============================================================*/
/* Table: PROCESSEDDEPLETIONSCORE                               */
/*==============================================================*/
create table PROCESSEDDEPLETIONSCORE (
   ENSG                 TEXT                 not null,
   CELLLINENAME         TEXT                 not null,
   DEPLETIONSCREEN      TEXT                 not null,
   CHRONOS              FLOAT4               null,
   CHRONOS_PROB         FLOAT4               null,
   D2                   FLOAT4               null,
   constraint PK_PROCESSEDDEPLETIONSCORE primary key (DEPLETIONSCREEN, CELLLINENAME, ENSG)
);

/*==============================================================*/
/* Table: PROCESSEDFUSIONGENE                                   */
/*==============================================================*/
create table PROCESSEDFUSIONGENE (
   PROCESSEDFUSION      INT4                 not null,
   CELLLINENAME         TEXT                 not null,
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
/* Table: PROCESSEDMETABOLITE                                   */
/*==============================================================*/
create table PROCESSEDMETABOLITE (
   METABOLITE           TEXT                 null,
   CELLLINENAME         TEXT                 null,
   SCORE                FLOAT4               null
);

/*==============================================================*/
/* Table: PROCESSEDPROLIFTEST                                   */
/*==============================================================*/
create table PROCESSEDPROLIFTEST (
   PROLIFTESTID         INT4                 not null,
   CELLLINENAME         TEXT                 not null,
   DRUGID               TEXT                 not null,
   CAMPAIGN             TEXT                 not null,
   LABORATORY           TEXT                 null,
   PROLIFERATIONTEST    TEXT                 null,
   TIMEPOINT_IN_HOURS   INT4                 null,
   TZERO                FLOAT4               null,
   TOP                  FLOAT4               null,
   BOTTOM               FLOAT4               null,
   SLOPE                FLOAT4               null,
   EC50                 FLOAT4               null,
   EC50OPERATOR         CHAR(1)              null,
   IC50                 FLOAT4               null,
   IC50PERATOR          CHAR(1)              null,
   GI50                 FLOAT4               null,
   GI50OPERATOR         CHAR(1)              null,
   ACTAREA              FLOAT4               null,
   AMAX                 FLOAT4               null,
   MAXCONC              FLOAT4               null,
   constraint PK_PROCESSEDPROLIFTEST primary key (PROLIFTESTID)
);

/*==============================================================*/
/* Table: PROCESSEDPROTEINEXPRESSION                            */
/*==============================================================*/
create table PROCESSEDPROTEINEXPRESSION (
   CELLLINENAME         TEXT                 not null,
   ANTIBODY             TEXT                 not null,
   SCORE                FLOAT4               null,
   constraint PK_PROCESSEDPROTEINEXPRESSION primary key (CELLLINENAME, ANTIBODY)
);

/*==============================================================*/
/* Table: PROCESSEDPROTEINMASSSPEC                              */
/*==============================================================*/
create table PROCESSEDPROTEINMASSSPEC (
   UNIPROTID            TEXT                 not null,
   ACCESSION            TEXT                 not null,
   ISOFORM              INT2                 not null,
   CELLLINENAME         TEXT                 not null,
   SCORE                FLOAT4               not null,
   constraint PK_PROCESSEDPROTEINMASSSPEC primary key (CELLLINENAME, UNIPROTID, ACCESSION, ISOFORM)
);

/*==============================================================*/
/* Table: PROCESSEDRNASEQ                                       */
/*==============================================================*/
create table PROCESSEDRNASEQ (
   RNASEQRUNID          TEXT                 not null,
   ENSG                 TEXT                 not null,
   LOG2TPM              REAL                 null,
   COUNTS               INT4                 null,
   constraint PK_PROCESSEDRNASEQ primary key (RNASEQRUNID, ENSG)
);

/*==============================================================*/
/* Table: PROCESSEDRNASEQTRANSCRIPT                             */
/*==============================================================*/
create table PROCESSEDRNASEQTRANSCRIPT (
   RNASEQRUNID          TEXT                 not null,
   ENST                 TEXT                 not null,
   LOG2TPM              REAL                 null,
   COUNTS               INT4                 null,
   constraint PK_PROCESSEDRNASEQTRANSCRIPT primary key (RNASEQRUNID, ENST)
);

/*==============================================================*/
/* Table: PROCESSEDSEQUENCE                                     */
/*==============================================================*/
create table PROCESSEDSEQUENCE (
   CELLLINENAME         TEXT                 not null,
   ENST                 TEXT                 not null,
   DNAMUTATION          TEXT                 null,
   DNAMUTATION_TRUNCATED TEXT                 null,
   AAMUTATION           TEXT                 null,
   AAMUTATION_TRUNCATED TEXT                 null,
   DNAZYGOSITY          FLOAT4               null,
   RNAZYGOSITY          FLOAT4               null,
   EXONSCOMPLETE        FLOAT4               null,
   CONFIRMEDDETAIL      BOOL                 null,
   NUMSOURCES           INT2                 null,
   constraint PK_PROCESSEDSEQUENCE primary key (CELLLINENAME, ENST)
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
   CELLLINENAME         TEXT                 null,
   NGSPROTOCOLID        INT4                 null,
   RNASEQGROUPID        INT4                 null,
   LABORATORY           TEXT                 null,
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
/* Table: SIMILARITY                                            */
/*==============================================================*/
create table SIMILARITY (
   SIMILARITYID         INT4                 not null,
   CELLLINENAME         TEXT                 not null,
   SIMILARITYTYPE       TEXT                 null,
   SOURCE               TEXT                 null,
   COMMENT              TEXT                 null,
   constraint PK_SIMILARITY primary key (SIMILARITYID, CELLLINENAME)
);

alter table ALTERNATIVE_CELLLINENAME
   add constraint FK_ALTERNAT_REFERENCE_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table CELLLINE2GENESIGNATURE
   add constraint FK_CELLLINE_REFERENCE_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete cascade on update cascade;

alter table CELLLINE2GENESIGNATURE
   add constraint FK_CELLLINE_REFERENCE_GENESIGN foreign key (SIGNATURE)
      references GENESIGNATURE (SIGNATURE)
      on delete cascade on update cascade;

alter table CELLLINEASSIGNMENT
   add constraint FK_CELLLINE_Assignment foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table CELLLINEASSIGNMENT
   add constraint FK_CELLLINE_ASSIGNMENT_PANEL foreign key (CELLLINEPANEL)
      references CELLLINEPANEL (CELLLINEPANEL)
      on delete restrict on update restrict;

alter table DNASEQRUN
   add constraint FK_DNASEQRU_REFERENCE_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table FUSIONDESCRIPTION
   add constraint FK_FUSIONDE_REFERENCE_PROCESSE foreign key (PROCESSEDFUSION)
      references PROCESSEDFUSIONGENE (PROCESSEDFUSION)
      on delete restrict on update restrict;

alter table FUSIONDESCRIPTION
   add constraint FK_FUSIONDE_REFERENCE_FUSIONTY foreign key (FUSIONTYPE)
      references FUSIONTYPE (FUSIONTYPE)
      on delete restrict on update restrict;

alter table HLATYPE
   add constraint FK_HLATYPE_REFERENCE_RNASEQRU foreign key (RNASEQRUNID)
      references RNASEQRUN (RNASEQRUNID)
      on delete cascade on update restrict;

alter table METMAP
   add constraint FK_METMAP_REFERENCE_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table MICROSATELLITEINSTABILITY
   add constraint FK_MICROSAT_REFERENCE_DNASEQRU foreign key (DNASEQRUNID)
      references DNASEQRUN (DNASEQRUNID)
      on delete cascade on update cascade;

alter table MUTATIONAL_SIGNATURE_PROFILE
   add constraint FK_MUTATION_REFERENCE_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table MUTATIONAL_SIGNATURE_PROFILE
   add constraint FK_MUTATION_REFERENCE_MUTATION foreign key (MUTATIONAL_SIGNATURE)
      references MUTATIONAL_SIGNATURE (MUTATIONAL_SIGNATURE)
      on delete restrict on update restrict;

alter table PROCESSEDCOMBIPROLIFTEST
   add constraint FK_PROCESSE_DRUG1 foreign key (DRUGID1)
      references DRUG (DRUGID)
      on delete restrict on update restrict;

alter table PROCESSEDCOMBIPROLIFTEST
   add constraint FK_PROCESSE_DRUG2 foreign key (DRUGID2)
      references DRUG (DRUGID)
      on delete restrict on update restrict;

alter table PROCESSEDCOMBIPROLIFTEST
   add constraint FK_PROCESSE_REFERENCE_CAMPAIGN foreign key (CAMPAIGN)
      references CAMPAIGN (CAMPAIGN)
      on delete restrict on update restrict;

alter table PROCESSEDCOMBIPROLIFTEST
   add constraint FK_PROLIFCOMBI_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table PROCESSEDCOMBIPROLIFTEST
   add constraint FK_PROCESSE_REFERENCE_LABORATO foreign key (LABORATORY)
      references LABORATORY (LABORATORY)
      on delete restrict on update restrict;

alter table PROCESSEDCOPYNUMBER
   add constraint FK_PROCESSE_CopyNumber_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table PROCESSEDCOPYNUMBER
   add constraint FK_PROCESSEDCOPY_2_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete cascade on update cascade;

alter table PROCESSEDDEPLETIONSCORE
   add constraint FK_PROCESSE_REFERENCE_DEPLETIO foreign key (DEPLETIONSCREEN)
      references DEPLETIONSCREEN (DEPLETIONSCREEN)
      on delete restrict on update restrict;

alter table PROCESSEDDEPLETIONSCORE
   add constraint FK_PROCESSE_REFERENCE_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table PROCESSEDDEPLETIONSCORE
   add constraint FK_PROCESSED_DEPLETION_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table PROCESSEDFUSIONGENE
   add constraint FK_Fusion_GENE1 foreign key (ENSG1)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table PROCESSEDFUSIONGENE
   add constraint FK_fusion_GENE2 foreign key (ENSG2)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table PROCESSEDFUSIONGENE
   add constraint FK_PROCESSEDFUSION_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table PROCESSEDMETABOLITE
   add constraint FK_PROCESSE_CELLLINE2_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table PROCESSEDMETABOLITE
   add constraint FK_PROCESSE_METABOLIT_METABOLI foreign key (METABOLITE)
      references METABOLITE (METABOLITE)
      on delete restrict on update restrict;

alter table PROCESSEDPROLIFTEST
   add constraint FK_PROCESSE_REFERENCE_DRUG foreign key (DRUGID)
      references DRUG (DRUGID)
      on delete restrict on update restrict;

alter table PROCESSEDPROLIFTEST
   add constraint FK_PROCESSE_REFERENCE_CAMPAIGN foreign key (CAMPAIGN)
      references CAMPAIGN (CAMPAIGN)
      on delete restrict on update restrict;

alter table PROCESSEDPROLIFTEST
   add constraint FK_PROLIFTEST_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table PROCESSEDPROLIFTEST
   add constraint FK_PROCESSE_REFERENCE_LABORATO foreign key (LABORATORY)
      references LABORATORY (LABORATORY)
      on delete restrict on update restrict;

alter table PROCESSEDPROTEINEXPRESSION
   add constraint FK_PROCESSE_PROT_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table PROCESSEDPROTEINEXPRESSION
   add constraint FK_PROCESSE_REFERENCE_ANTIBODY foreign key (ANTIBODY)
      references ANTIBODY (ANTIBODY)
      on delete restrict on update restrict;

alter table PROCESSEDPROTEINMASSSPEC
   add constraint FK_PROCESSPROTMASS_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table PROCESSEDPROTEINMASSSPEC
   add constraint FK_PROCESSE_REFERENCE_UNIPROTA foreign key (UNIPROTID, ACCESSION)
      references UNIPROTACCESSION (UNIPROTID, ACCESSION)
      on delete restrict on update restrict;

alter table PROCESSEDRNASEQ
   add constraint FK_PROCESSEDRNASEQ_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete cascade on update cascade;

alter table PROCESSEDRNASEQ
   add constraint FK_PROCESSE_REFERENCE_RNASEQRU foreign key (RNASEQRUNID)
      references RNASEQRUN (RNASEQRUNID)
      on delete cascade on update cascade;

alter table PROCESSEDRNASEQTRANSCRIPT
   add constraint FK_RNASEQTRANS_TRANSCRIPTS foreign key (ENST)
      references TRANSCRIPT (ENST)
      on delete cascade on update cascade;

alter table PROCESSEDRNASEQTRANSCRIPT
   add constraint FK_RNASEQTRANS_NGSRUN foreign key (RNASEQRUNID)
      references RNASEQRUN (RNASEQRUNID)
      on delete cascade on update cascade;

alter table PROCESSEDSEQUENCE
   add constraint FK_PROCESSE_REFERENCE_TRANSCRI foreign key (ENST)
      references TRANSCRIPT (ENST)
      on delete cascade on update cascade;

alter table PROCESSEDSEQUENCE
   add constraint FK_PROCESSEDSequence_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table RNASEQRUN
   add constraint FK_RNASEQRU_REFERENCE_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete restrict on update restrict;

alter table RNASEQRUN
   add constraint FK_RNASEQRU_REFERENCE_NGSPROTO foreign key (NGSPROTOCOLID)
      references NGSPROTOCOL (NGSPROTOCOLID)
      on delete restrict on update restrict;

alter table RNASEQRUN
   add constraint FK_RNASEQRU_REFERENCE_RNASEQGR foreign key (RNASEQGROUPID)
      references RNASEQGROUP (RNASEQGROUPID)
      on delete restrict on update restrict;

alter table RNASEQRUN
   add constraint FK_RNASEQRU_REFERENCE_LABORATO foreign key (LABORATORY)
      references LABORATORY (LABORATORY)
      on delete restrict on update restrict;

alter table SIMILARITY
   add constraint FK_SIMILARI_REFERENCE_CELLLINE foreign key (CELLLINENAME)
      references CELLLINE (CELLLINENAME)
      on delete cascade on update cascade;

alter table SIMILARITY
   add constraint FK_SIMILARI_REFERENCE_SIMILARI foreign key (SIMILARITYTYPE)
      references SIMILARITYTYPE (SIMILARITYTYPE)
      on delete cascade on update cascade;

