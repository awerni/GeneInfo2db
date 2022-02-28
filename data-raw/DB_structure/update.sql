set search_path = cellline,public;

alter table CELLLINE2GENESIGNATURE
   add constraint FK_CELLLINE_REFERENCE_GENESIGN foreign key (SIGNATURE)
      references GENESIGNATURE (SIGNATURE)
      on delete cascade on update cascade;
alter table FUSIONDESCRIPTION
   add constraint FK_FUSIONDE_REFERENCE_FUSIONTY foreign key (FUSIONTYPE)
      references FUSIONTYPE (FUSIONTYPE)
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
   add constraint FK_PROCESSE_REFERENCE_LABORATO foreign key (LABORATORY)
      references LABORATORY (LABORATORY)
      on delete restrict on update restrict;
alter table PROCESSEDCOPYNUMBER
   add constraint FK_PROCESSEDCOPY_2_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete cascade on update cascade;
alter table PROCESSEDDEPLETIONSCORE
   add constraint FK_PROCESSE_REFERENCE_GENE foreign key (ENSG)
      references GENE (ENSG)
      on delete restrict on update restrict;
alter table PROCESSEDFUSIONGENE
   add constraint FK_fusion_GENE2 foreign key (ENSG2)
      references GENE (ENSG)
      on delete restrict on update restrict;
alter table PROCESSEDFUSIONGENE
   add constraint FK_Fusion_GENE1 foreign key (ENSG1)
      references GENE (ENSG)
      on delete restrict on update restrict;
alter table PROCESSEDPROLIFTEST
   add constraint FK_PROCESSE_REFERENCE_DRUG foreign key (DRUGID)
      references DRUG (DRUGID)
      on delete restrict on update restrict;
alter table PROCESSEDPROLIFTEST
   add constraint FK_PROCESSE_REFERENCE_LABORATO foreign key (LABORATORY)
      references LABORATORY (LABORATORY)
      on delete restrict on update restrict;
alter table PROCESSEDPROTEINEXPRESSION
   add constraint FK_PROCESSE_REFERENCE_ANTIBODY foreign key (ANTIBODY)
      references ANTIBODY (ANTIBODY)
      on delete restrict on update restrict;
alter table PROCESSEDPROTEINMASSSPEC
  add constraint FK_PROCESSE_REFERENCE_UNIPROTA foreign key (UNIPROTID, ACCESSION)
      references UNIPROTACCESSION (UNIPROTID, ACCESSION)
      on delete restrict on update restrict;
alter table PROCESSEDRNASEQTRANSCRIPT
   add constraint FK_RNASEQTRANS_TRANSCRIPTS foreign key (ENST)
      references TRANSCRIPT (ENST)
      on delete cascade on update cascade;
alter table PROCESSEDSEQUENCE
   add constraint FK_PROCESSE_REFERENCE_TRANSCRI foreign key (ENST)
      references TRANSCRIPT (ENST)
      on delete cascade on update cascade;
alter table RNASEQRUN
   add constraint FK_RNASEQRU_REFERENCE_NGSPROTO foreign key (NGSPROTOCOLID)
      references NGSPROTOCOL (NGSPROTOCOLID)
      on delete restrict on update restrict;
alter table RNASEQRUN
   add constraint FK_RNASEQRU_REFERENCE_LABORATO foreign key (LABORATORY)
      references LABORATORY (LABORATORY)
      on delete restrict on update restrict;
alter table SIMILARITY
   add constraint FK_SIMILARI_REFERENCE_SIMILARI foreign key (SIMILARITYTYPE)
      references SIMILARITYTYPE (SIMILARITYTYPE)
      on delete cascade on update cascade;
