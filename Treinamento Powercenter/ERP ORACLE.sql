--------------------------------------------------------
--  File created - Thursday-May-16-2019   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table CATEGORIA
--------------------------------------------------------

  CREATE TABLE "SDBU"."CATEGORIA" 
   (	"IDCATEGORIA" NUMBER(10,0), 
	"CATEGORIA" VARCHAR2(100 BYTE)
   ) ;
   
--------------------------------------------------------
--  Constraints for Table CATEGORIA
--------------------------------------------------------

  ALTER TABLE "SDBU"."CATEGORIA" MODIFY ("IDCATEGORIA" NOT NULL ENABLE);
  ALTER TABLE "SDBU"."CATEGORIA" ADD CONSTRAINT "CATEGORIA_PKEY" PRIMARY KEY ("IDCATEGORIA");

  
--------------------------------------------------------
--  DDL for Table CLIENTES
--------------------------------------------------------

  CREATE TABLE "SDBU"."CLIENTES" 
   (	"IDCLIENTE" NUMBER(10,0), 
	"CLIENTE" VARCHAR2(50 BYTE), 
	"ESTADO" VARCHAR2(2 BYTE), 
	"SEXO" CHAR(1 BYTE), 
	"STATUS" VARCHAR2(50 BYTE)
   ) ;
  
--------------------------------------------------------
--  Constraints for Table CLIENTES
--------------------------------------------------------

  ALTER TABLE "SDBU"."CLIENTES" MODIFY ("IDCLIENTE" NOT NULL ENABLE);
  ALTER TABLE "SDBU"."CLIENTES" ADD CONSTRAINT "CLIENTES_PKEY" PRIMARY KEY ("IDCLIENTE");    
  
  
--------------------------------------------------------
--  DDL for Table CLIENTE_ATR
--------------------------------------------------------

  CREATE TABLE "SDBU"."CLIENTE_ATR" 
   (	"IDCLIENTE" NUMBER(10,0), 
	"DTNASCIMENTO" DATE
   ) ;

--------------------------------------------------------
--  Ref Constraints for Table CLIENTE_ATR
--------------------------------------------------------

  ALTER TABLE"SDBU"."CLIENTE_ATR"  ADD CONSTRAINT "CLIENTE_ATR_IDCLIENTE_FKEY" FOREIGN KEY ("IDCLIENTE")
	  REFERENCES "SDBU"."CLIENTES" ("IDCLIENTE") ENABLE;

--------------------------------------------------------
--  Constraints for Table CLIENTE_ATR
--------------------------------------------------------

  ALTER TABLE "SDBU"."CLIENTE_ATR" MODIFY ("IDCLIENTE" NOT NULL ENABLE);
  ALTER TABLE "SDBU"."CLIENTE_ATR" MODIFY ("DTNASCIMENTO" NOT NULL ENABLE);
  
  

--------------------------------------------------------
--  DDL for Table PRODUTOS
--------------------------------------------------------

  CREATE TABLE "SDBU"."PRODUTOS" 
   (	"IDPRODUTO" NUMBER(10,0), 
	"PRODUTO" VARCHAR2(100 BYTE), 
	"PRECO" NUMBER(10,2)
   );
  
--------------------------------------------------------
--  Constraints for Table PRODUTOS
--------------------------------------------------------

  ALTER TABLE "SDBU"."PRODUTOS" MODIFY ("IDPRODUTO" NOT NULL ENABLE);
  ALTER TABLE "SDBU"."PRODUTOS" ADD CONSTRAINT "PRODUTOS_PKEY" PRIMARY KEY ("IDPRODUTO");

    

--------------------------------------------------------
--  DDL for Table VINCULACAO_PRODUTO_CATEGORIA
--------------------------------------------------------

  CREATE TABLE "SDBU"."VINCULACAO_PRODUTO_CATEGORIA" 
   (	"IDVINCULACAO" NUMBER(10,0), 
	"IDCATEGORIA" NUMBER(10,0), 
	"IDPRODUTO" NUMBER(10,0)
   ) ;

--------------------------------------------------------
--  Constraints for Table VINCULACAO_PRODUTO_CATEGORIA
--------------------------------------------------------

  ALTER TABLE "SDBU"."VINCULACAO_PRODUTO_CATEGORIA" MODIFY ("IDVINCULACAO" NOT NULL ENABLE);
  ALTER TABLE "SDBU"."VINCULACAO_PRODUTO_CATEGORIA" MODIFY ("IDCATEGORIA" NOT NULL ENABLE);
  ALTER TABLE "SDBU"."VINCULACAO_PRODUTO_CATEGORIA" MODIFY ("IDPRODUTO" NOT NULL ENABLE);
  ALTER TABLE "SDBU"."VINCULACAO_PRODUTO_CATEGORIA" ADD CONSTRAINT "VINCULACAO_PKEY" PRIMARY KEY ("IDVINCULACAO");
    
  ALTER TABLE "SDBU"."VINCULACAO_PRODUTO_CATEGORIA" ADD CONSTRAINT "VINCULACAO_CATEGORIA_FKEY" FOREIGN KEY (IDCATEGORIA)
	  REFERENCES "SDBU"."CATEGORIA" ("IDCATEGORIA") ENABLE;
    
  ALTER TABLE "SDBU"."VINCULACAO_PRODUTO_CATEGORIA" ADD CONSTRAINT "VINCULACAO_PRODUTO_FKEY" FOREIGN KEY ("IDPRODUTO")
	  REFERENCES "SDBU"."PRODUTOS" ("IDPRODUTO") ENABLE;



--------------------------------------------------------
--  DDL for Table VENDEDORES
--------------------------------------------------------

  CREATE TABLE "SDBU"."VENDEDORES" 
   (	"IDVENDEDOR" NUMBER(10,0), 
	"NOME" VARCHAR2(50 BYTE)
   ) ;
   

--------------------------------------------------------
--  Constraints for Table VENDEDORES
--------------------------------------------------------

  ALTER TABLE "SDBU"."VENDEDORES" MODIFY ("IDVENDEDOR" NOT NULL ENABLE);
  ALTER TABLE "SDBU"."VENDEDORES" ADD CONSTRAINT "VENDEDORES_PKEY" PRIMARY KEY ("IDVENDEDOR");
   
   






--------------------------------------------------------
--  DDL for Table VENDAS
--------------------------------------------------------

  CREATE TABLE "SDBU"."VENDAS" 
   (	"IDVENDA" NUMBER(10,0), 
	"IDVENDEDOR" NUMBER(10,0), 
	"IDCLIENTE" NUMBER(10,0), 
	"DATA" DATE, 
	"TOTAL" NUMBER(10,2)
   ) ;

--------------------------------------------------------
--  Constraints for Table VENDAS
--------------------------------------------------------

  ALTER TABLE "SDBU"."VENDAS" MODIFY ("IDVENDA" NOT NULL ENABLE);
  ALTER TABLE "SDBU"."VENDAS" ADD CONSTRAINT "VENDAS_PKEY" PRIMARY KEY ("IDVENDA")  ;
--------------------------------------------------------
--  Ref Constraints for Table VENDAS
--------------------------------------------------------

  ALTER TABLE "SDBU"."VENDAS" ADD CONSTRAINT "VENDAS_IDCLIENTE_FKEY" FOREIGN KEY ("IDCLIENTE")
	  REFERENCES "SDBU"."CLIENTES" ("IDCLIENTE") ENABLE;
  ALTER TABLE "SDBU"."VENDAS" ADD CONSTRAINT "VENDAS_IDVENDEDOR_FKEY" FOREIGN KEY ("IDVENDEDOR")
	  REFERENCES "SDBU"."VENDEDORES" ("IDVENDEDOR") ENABLE;
  

   
   
   


--------------------------------------------------------
--  DDL for Table ITENSVENDA
--------------------------------------------------------

  CREATE TABLE "SDBU"."ITENSVENDA" 
   (	"IDPRODUTO" NUMBER(10,0), 
	"IDVENDA" NUMBER(10,0), 
	"QUANTIDADE" NUMBER(10,0), 
	"VALORUNITARIO" NUMBER(10,2), 
	"VALORTOTAL" NUMBER(10,2), 
	"DESCONTO" NUMBER(10,2)
   ) ;
   
   
   
   
--------------------------------------------------------
--  Constraints for Table ITENSVENDA
--------------------------------------------------------

  ALTER TABLE "SDBU"."ITENSVENDA" MODIFY ("IDPRODUTO" NOT NULL ENABLE);
  ALTER TABLE "SDBU"."ITENSVENDA" MODIFY ("IDVENDA" NOT NULL ENABLE);
  ALTER TABLE "SDBU"."ITENSVENDA" ADD CONSTRAINT "ITENSVENDA_PKEY" PRIMARY KEY ("IDPRODUTO", "IDVENDA");
    
--------------------------------------------------------
--  Ref Constraints for Table ITENSVENDA
--------------------------------------------------------

  ALTER TABLE "SDBU"."ITENSVENDA" ADD CONSTRAINT "ITENSVENDA_IDPRODUTO_FKEY" FOREIGN KEY ("IDPRODUTO")
	  REFERENCES "SDBU"."PRODUTOS" ("IDPRODUTO") ENABLE;
  ALTER TABLE "SDBU"."ITENSVENDA" ADD CONSTRAINT "ITENSVENDA_IDVENDA_FKEY" FOREIGN KEY ("IDVENDA")
	  REFERENCES "SDBU"."VENDAS" ("IDVENDA") ENABLE;


