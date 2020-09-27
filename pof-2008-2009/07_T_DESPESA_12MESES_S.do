** ---------------------------------------------------- **
** --                REGISTRO TIPO 07                -- **
** -- DESPESAS DE 12 MESES - POF 2 / QUADROS 10 A 13 -- **
** ---------------------------------------------------- **

cd "~\OneDrive\ministery\first_base\our_datas\append_8_databases"

infix Tipo_de_registro                     1-2 ///  v1
      Codigo_da_UF                         3-4 ///  v2
      Numero_sequencial                    5-7 ///  v3
      DV_do_sequencial                       8 ///  v4
      Numero_do_domicilio                 9-10 ///  v5
      Numero_da_UC                          11 ///  v6
      Estrato_geografico                 12-13 ///  v7
      Fator_de_expansao_1                14-27 ///  v8
      Fator_de_expansao_2                28-41 ///  v9
      Numero_do_quadro                   42-43 /// v10
      Codigo_do_item                     44-48 /// v11
      Forma_de_aquisicao                 49-50 /// v12
      Valor_da_despesa                   51-61 /// v13
      Mes_da_ultima_despesa              62-63 /// v14
      Numero_de_meses                    64-65 /// v15
      Fator_de_anualizacao               66-67 /// v16
      Deflator_fator                     68-72 /// v17
      Valor_da_despesa_deflacionado      73-83 /// v18
      Despesa_anualizado_e_expandido     84-99 /// v19
      Codigo_de_imputacao              100-101 /// v20
      Renda_monetaria_mensal_da_UC     102-117 /// v21
      Renda_nao_monetaria_mensal_da_UC 118-133 /// v22
      Renda_total_mensal_da_UC         134-149 /// v23
      Codigo_do_local_de_aquisicao     150-154 using T_DESPESA_12MESES_S.txt

save "07_DESPESA_12MESES.dta"
