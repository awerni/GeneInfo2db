/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     8/19/2021 5:24:17 AM                         */
/*==============================================================*/


/*==============================================================*/
/* Table: ALTENSEMBLSYMBOL                                      */
/*==============================================================*/
create table ALTENSEMBLSYMBOL (
   ALTSYMBOL            TEXT                 not null,
   ENSG                 TEXT                 not null,
   constraint PK_ALTENSEMBLSYMBOL primary key (ALTSYMBOL, ENSG)
);

/*==============================================================*/
/* Table: ALTENTREZGENESYMBOL                                   */
/*==============================================================*/
create table ALTENTREZGENESYMBOL (
   GENEID               INTEGER              not null,
   SYMBOL               TEXT                 not null,
   constraint PK_ALTENTREZGENESYMBOL primary key (GENEID, SYMBOL)
);

/*==============================================================*/
/* Table: ANTIBODY                                              */
/*==============================================================*/
create table ANTIBODY (
   ANTIBODY             TEXT                 not null,
   VALIDATION_STATUS    TEXT                 not null,
   VENDOR               TEXT                 null,
   CATALOG_NUMBER       TEXT                 null,
   constraint PK_ANTIBODY primary key (ANTIBODY)
);

/*==============================================================*/
/* Table: CHIPTECHNOLOGY                                        */
/*==============================================================*/
create table CHIPTECHNOLOGY (
   CHIPNAME             TEXT                 not null,
   CHIPTYPE             TEXT                 null,
   ENZYME               TEXT                 null,
   constraint PK_CHIPTECHNOLOGY primary key (CHIPNAME)
);

/*==============================================================*/
/* Table: DATASTACK                                             */
/*==============================================================*/
create table DATASTACK (
   DATASTACKID          TEXT                 not null,
   PLAYLOAD             JSONB                null,
   CREATED              TIMESTAMP WITH TIME ZONE null,
   constraint PK_DATASTACK primary key (DATASTACKID)
);

/*==============================================================*/
/* Table: DRUG                                                  */
/*==============================================================*/
create table DRUG (
   DRUGID               TEXT                 not null,
   TARGET               TEXT                 null,
   COMMONNAME           TEXT                 null,
   SCIENTIFICNAME       TEXT                 null,
   MOA                  TEXT                 null,
   INDICATION           TEXT                 null,
   SMILES               TEXT                 null,
   PUBCHEMID            INT4                 null,
   constraint PK_DRUG primary key (DRUGID)
);

/*==============================================================*/
/* Table: ENTREZGENE                                            */
/*==============================================================*/
create table ENTREZGENE (
   GENEID               INTEGER              not null,
   TAXID                INTEGER              null,
   SYMBOL               TEXT                 null,
   GENENAME             TEXT                 null,
   CHROMOSOME           TEXT                 null,
   LOCALISATION         TEXT                 null,
   NUCLSTART            INT8                 null,
   NUCLEND              INT8                 null,
   STRAND               TEXT                 null,
   GENOMEASSEMBLY       TEXT                 null,
   constraint PK_ENTREZGENE primary key (GENEID)
);

/*==============================================================*/
/* Table: ENTREZGENE2ENSEMBLGENE                                */
/*==============================================================*/
create table ENTREZGENE2ENSEMBLGENE (
   ENSG                 TEXT                 not null,
   GENEID               INTEGER              not null,
   constraint PK_ENTREZGENE2ENSEMBLGENE primary key (ENSG, GENEID)
);

/*==============================================================*/
/* Table: EXON                                                  */
/*==============================================================*/
create table EXON (
   ENSE                 TEXT                 not null,
   CHROMOSOME           TEXT                 null,
   SEQSTART             INT4                 null,
   SEQEND               INT4                 null,
   constraint PK_EXON primary key (ENSE)
);

/*==============================================================*/
/* Table: FUSIONTYPE                                            */
/*==============================================================*/
create table FUSIONTYPE (
   FUSIONTYPE           TEXT                 not null,
   FUSIONDESCRIPTION    TEXT                 null,
   constraint PK_FUSIONTYPE primary key (FUSIONTYPE)
);

/*==============================================================*/
/* Table: GENE                                                  */
/*==============================================================*/
create table GENE (
   ENSG                 TEXT                 not null,
   SYMBOL               TEXT                 null,
   NAME                 TEXT                 null,
   CHROMOSOME           TEXT                 null,
   STRAND               INT2                 null,
   SEQREGIONSTART       INT4                 null,
   SEQREGIONEND         INT4                 null,
   BIOTYPE              TEXT                 null,
   COSMIC_ID_GENE       INT4                 null,
   GC_CONTENT           FLOAT4               null,
   SPECIES              TEXT                 not null,
   TDPID                SERIAL               not null,
   constraint PK_GENE primary key (ENSG)
);

/*==============================================================*/
/* Table: GENE2ANTIBODY                                         */
/*==============================================================*/
create table GENE2ANTIBODY (
   ENSG                 TEXT                 not null,
   ANTIBODY             TEXT                 not null,
   constraint PK_GENE2ANTIBODY primary key (ENSG, ANTIBODY)
);

/*==============================================================*/
/* Table: GENEASSIGNMENT                                        */
/*==============================================================*/
create table GENEASSIGNMENT (
   ENSG                 TEXT                 not null,
   GENESETNAME          TEXT                 not null,
   constraint PK_GENEASSIGNMENT primary key (ENSG, GENESETNAME)
);

/*==============================================================*/
/* Table: GENEEXPRESSIONCHIP                                    */
/*==============================================================*/
create table GENEEXPRESSIONCHIP (
   GENEEXPRESSIONCHIP   TEXT                 not null,
   DESCRIPTION          TEXT                 null,
   SOURCE               TEXT                 null,
   VERSION              TEXT                 null,
   TAXID                INTEGER              null,
   constraint PK_GENEEXPRESSIONCHIP primary key (GENEEXPRESSIONCHIP)
);

/*==============================================================*/
/* Table: GENESET                                               */
/*==============================================================*/
create table GENESET (
   GENESETNAME          TEXT                 not null,
   SPECIES              TEXT                 not null,
   constraint PK_GENESET primary key (GENESETNAME)
);

/*==============================================================*/
/* Table: GENESIGNATURE                                         */
/*==============================================================*/
create table GENESIGNATURE (
   SIGNATURE            TEXT                 not null,
   DESCRIPTION          TEXT                 null,
   UNIT                 TEXT                 null,
   HYPERLINK            TEXT                 null,
   constraint PK_GENESIGNATURE primary key (SIGNATURE)
);

/*==============================================================*/
/* Table: HOMOLOGENE                                            */
/*==============================================================*/
create table HOMOLOGENE (
   HOMOLOGENECLUSTER    INT4                 not null,
   GENEID               INTEGER              not null,
   constraint PK_HOMOLOGENE primary key (HOMOLOGENECLUSTER, GENEID)
);

/*==============================================================*/
/* Table: INFORMATION                                           */
/*==============================================================*/
create table INFORMATION (
   DESCRIPTION          TEXT                 not null,
   INFORMATION          TEXT                 null,
   constraint PK_INFORMATION primary key (DESCRIPTION)
);

/*==============================================================*/
/* Table: LABORATORY                                            */
/*==============================================================*/
create table LABORATORY (
   LABORATORY           TEXT                 not null,
   constraint PK_LABORATORY primary key (LABORATORY)
);

/*==============================================================*/
/* Table: MIRBASE                                               */
/*==============================================================*/
create table MIRBASE (
   ACCESSION            TEXT                 not null,
   ID                   TEXT                 null,
   STATUS               TEXT                 null,
   SEQUENCE             TEXT                 null,
   constraint PK_MIRBASE primary key (ACCESSION)
);

/*==============================================================*/
/* Table: MIRBASE2ENSEMBLGENE                                   */
/*==============================================================*/
create table MIRBASE2ENSEMBLGENE (
   ENSG                 TEXT                 not null,
   ACCESSION            TEXT                 not null,
   constraint PK_MIRBASE2ENSEMBLGENE primary key (ENSG, ACCESSION)
);

/*==============================================================*/
/* Table: MIRBASEMATURESEQ                                      */
/*==============================================================*/
create table MIRBASEMATURESEQ (
   ACCESSION            TEXT                 not null,
   MATURE_ACC           TEXT                 not null,
   MATURE_ID            TEXT                 null,
   MATURE_SEQUENCE      TEXT                 null,
   constraint PK_MIRBASEMATURESEQ primary key (ACCESSION, MATURE_ACC)
);

/*==============================================================*/
/* Table: MSIGDB                                                */
/*==============================================================*/
create table MSIGDB (
   GENE_SET             TEXT                 not null,
   SPECIES              TEXT                 not null,
   COLLECTION           TEXT                 null,
   COLLECTION_NAME      TEXT                 null,
   GENE_SET_GROUP       TEXT                 null,
   ENSG_ARRAY           TEXT[]               null,
   constraint PK_MSIGDB primary key (GENE_SET, SPECIES)
);

/*==============================================================*/
/* Table: MUTATIONBLACKLIST                                     */
/*==============================================================*/
create table MUTATIONBLACKLIST (
   STARTPOS             INT8                 null,
   CHROMOSOME           TEXT                 null,
   ENST                 TEXT                 null,
   CDNAMUTATION         TEXT                 null
);

/*==============================================================*/
/* Table: MUTATIONEFFECT                                        */
/*==============================================================*/
create table MUTATIONEFFECT (
   MUTATIONEFFECT       TEXT                 not null,
   DESCRIPTION          TEXT                 null,
   IMPACT               TEXT                 null,
   constraint PK_MUTATIONEFFECT primary key (MUTATIONEFFECT)
);

/*==============================================================*/
/* Table: MUTATIONTYPE                                          */
/*==============================================================*/
create table MUTATIONTYPE (
   MUTATIONTYPE         TEXT                 not null,
   DESCRIPTION          TEXT                 null,
   constraint PK_MUTATIONTYPE primary key (MUTATIONTYPE)
);

/*==============================================================*/
/* Table: NGSPROTOCOL                                           */
/*==============================================================*/
create table NGSPROTOCOL (
   NGSPROTOCOLID        INT4                 not null,
   NGSPROTOCOLNAME      TEXT                 null,
   PLEXITY              INT2                 null,
   STRANDNESS           TEXT                 null,
   RNASELECTION         TEXT                 null,
   constraint PK_NGSPROTOCOL primary key (NGSPROTOCOLID)
);

/*==============================================================*/
/* Table: PROBESET                                              */
/*==============================================================*/
create table PROBESET (
   GENEEXPRESSIONCHIP   TEXT                 not null,
   PROBESET             TEXT                 not null,
   ENSG                 TEXT                 null,
   GENEID               INTEGER              null,
   CANONICAL            BOOL                 null,
   PROBES               INT2                 null,
   MATCHES              INT2                 null,
   XHYBS                INT2                 null,
   FOUNDVIASEQMATCH     BOOL                 null,
   RNASEQCORRELATION    REAL                 null,
   CANONICALGSK         BOOL                 null,
   RNASEQCORRELATIONGSK REAL                 null,
   constraint PK_PROBESET primary key (GENEEXPRESSIONCHIP, PROBESET)
);

/*==============================================================*/
/* Table: PROTEIN                                               */
/*==============================================================*/
create table PROTEIN (
   ENSP                 TEXT                 not null,
   ENST                 TEXT                 null,
   PROTEINNAME          TEXT                 null,
   constraint PK_PROTEIN primary key (ENSP)
);

/*==============================================================*/
/* Table: REFSEQ                                                */
/*==============================================================*/
create table REFSEQ (
   REFSEQID             TEXT                 not null,
   GENEID               INTEGER              null,
   TAXID                INTEGER              not null,
   REFSEQDESC           TEXT                 null,
   CDNASEQUENCE         TEXT                 not null,
   constraint PK_REFSEQ primary key (REFSEQID)
);

/*==============================================================*/
/* Table: SIMILARITYTYPE                                        */
/*==============================================================*/
create table SIMILARITYTYPE (
   SIMILARITYTYPE       TEXT                 not null,
   SIMILARITYDESCRIPTION TEXT                 null,
   constraint PK_SIMILARITYTYPE primary key (SIMILARITYTYPE)
);

/*==============================================================*/
/* Table: TRANSCRIPT                                            */
/*==============================================================*/
create table TRANSCRIPT (
   ENST                 TEXT                 not null,
   ENSG                 TEXT                 null,
   TRANSCRIPTNAME       TEXT                 null,
   CHROMOSOME           TEXT                 null,
   STRAND               INT2                 null,
   SEQSTART             INT4                 null,
   SEQEND               INT4                 null,
   ISCANONICAL          BOOL                 null,
   COSMIC_ID_TRANSCRIPT INT4                 null,
   ENSP                 TEXT                 null,
   constraint PK_TRANSCRIPT primary key (ENST)
);

/*==============================================================*/
/* Table: TRANSCRIPT2EXON                                       */
/*==============================================================*/
create table TRANSCRIPT2EXON (
   ENST                 TEXT                 not null,
   ENSE                 TEXT                 not null,
   EXON                 INT2                 null,
   TRANSSTART           INT4                 null,
   TRANSEND             INT4                 null,
   constraint PK_TRANSCRIPT2EXON primary key (ENST, ENSE)
);

/*==============================================================*/
/* Table: UNIPROT                                               */
/*==============================================================*/
create table UNIPROT (
   UNIPROTID            TEXT                 not null,
   PROTEINNAME          TEXT                 null,
   constraint PK_UNIPROT primary key (UNIPROTID)
);

/*==============================================================*/
/* Table: UNIPROT2ENSEMBLGENE                                   */
/*==============================================================*/
create table UNIPROT2ENSEMBLGENE (
   UNIPROTID            TEXT                 null,
   ENSG                 TEXT                 null
);

/*==============================================================*/
/* Table: UNIPROT2ENTREZGENE                                    */
/*==============================================================*/
create table UNIPROT2ENTREZGENE (
   GENEID               INTEGER              null,
   UNIPROTID            TEXT                 null
);

/*==============================================================*/
/* Table: UNIPROTACCESSION                                      */
/*==============================================================*/
create table UNIPROTACCESSION (
   UNIPROTID            TEXT                 not null,
   ACCESSION            TEXT                 not null,
   constraint PK_UNIPROTACCESSION primary key (UNIPROTID, ACCESSION)
);

alter table ALTENSEMBLSYMBOL
   add constraint FK_ALTENSEM_REFERENCE_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table ALTENTREZGENESYMBOL
   add constraint FK_ALTENTREZSYMBOL_ENTREZGENE foreign key (GENEID)
      references ENTREZGENE (GENEID)
      on delete cascade on update cascade;

alter table ENTREZGENE2ENSEMBLGENE
   add constraint FK_ENTREZGE_REFERENCE_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table ENTREZGENE2ENSEMBLGENE
   add constraint FK_ENTREZ2ENSE_GENE foreign key (GENEID)
      references ENTREZGENE (GENEID)
      on delete cascade on update cascade;

alter table GENE2ANTIBODY
   add constraint FK_GENE2ANT_REFERENCE_ANTIBODY foreign key (ANTIBODY)
      references ANTIBODY (ANTIBODY)
      on delete restrict on update restrict;

alter table GENE2ANTIBODY
   add constraint FK_GENE2ANT_REFERENCE_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table GENEASSIGNMENT
   add constraint FK_GENEASSI_REFERENCE_GENESET foreign key (GENESETNAME)
      references GENESET (GENESETNAME)
      on delete cascade on update cascade;

alter table GENEASSIGNMENT
   add constraint FK_GENEASSI_REFERENCE_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete cascade on update restrict;

alter table HOMOLOGENE
   add constraint FK_HOMOLOGENE_ENTREZGENE foreign key (GENEID)
      references ENTREZGENE (GENEID)
      on delete cascade on update cascade;

alter table MIRBASE2ENSEMBLGENE
   add constraint FK_MIRBASE2_REFERENCE_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table MIRBASE2ENSEMBLGENE
   add constraint FK_MIRBASE2_REFERENCE_MIRBASE foreign key (ACCESSION)
      references MIRBASE (ACCESSION)
      on delete cascade on update cascade;

alter table MIRBASEMATURESEQ
   add constraint FK_MIRBASEM_REFERENCE_MIRBASE foreign key (ACCESSION)
      references MIRBASE (ACCESSION)
      on delete cascade on update cascade;

alter table MUTATIONBLACKLIST
   add constraint FK_MUTATIONBLACK_TRANSCRIPT foreign key (ENST)
      references TRANSCRIPT (ENST)
      on delete restrict on update restrict;

alter table PROBESET
   add constraint FK_PROBESET_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table PROBESET
   add constraint FK_PROBESET_REFERENCE_GENEEXPR foreign key (GENEEXPRESSIONCHIP)
      references GENEEXPRESSIONCHIP (GENEEXPRESSIONCHIP)
      on delete cascade on update cascade;

alter table PROBESET
   add constraint FK_PROBESET_ENTREZGENE foreign key (GENEID)
      references ENTREZGENE (GENEID)
      on delete cascade on update cascade;

alter table PROTEIN
   add constraint FK_PROTEIN_REFERENCE_TRANSCRI foreign key (ENST)
      references TRANSCRIPT (ENST)
      on delete restrict on update restrict;

alter table REFSEQ
   add constraint FK_REFSEQ_ENTREZGENE foreign key (GENEID)
      references ENTREZGENE (GENEID)
      on delete cascade on update cascade;

alter table TRANSCRIPT
   add constraint FK_TRANSCRI_REFERENCE_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete restrict on update cascade;

alter table TRANSCRIPT2EXON
   add constraint FK_TRANSCRI_REFERENCE_EXON foreign key (ENSE)
      references EXON (ENSE)
      on delete restrict on update restrict;

alter table TRANSCRIPT2EXON
   add constraint FK_TRANSCRI_REFERENCE_TRANSCRI foreign key (ENST)
      references TRANSCRIPT (ENST)
      on delete restrict on update restrict;

alter table UNIPROT2ENSEMBLGENE
   add constraint FK_UNIPROT2_REFERENCE_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete restrict on update restrict;

alter table UNIPROT2ENSEMBLGENE
   add constraint FK_UNIPROT2_UNIPROT2gene foreign key (UNIPROTID)
      references UNIPROT (UNIPROTID)
      on delete restrict on update restrict;

alter table UNIPROT2ENTREZGENE
   add constraint FK_UNIPROT2_REFERENCE_ENTREZGE foreign key (GENEID)
      references ENTREZGENE (GENEID)
      on delete restrict on update restrict;

alter table UNIPROT2ENTREZGENE
   add constraint FK_UNIPROT2_UNIPROT2entrez foreign key (UNIPROTID)
      references UNIPROT (UNIPROTID)
      on delete restrict on update restrict;

alter table UNIPROTACCESSION
   add constraint FK_UNIPROTA_REFERENCE_UNIPROT foreign key (UNIPROTID)
      references UNIPROT (UNIPROTID)
      on delete restrict on update restrict;

