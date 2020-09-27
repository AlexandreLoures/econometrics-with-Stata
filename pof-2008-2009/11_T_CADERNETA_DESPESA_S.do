** ---------------------------------- **
** --       REGISTRO TIPO 11       -- **
** -- CADERNETA DE DESPESA - POF 3 -- **
** ---------------------------------- **

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
      Numero_do_grupo_de_despesa         44-45 /// v11
      Codigo_do_item                     46-50 /// v12
      Forma_de_aquisicao                 51-52 /// v13
      Valor_da_despesa                   53-63 /// v14
      Fator_de_anualizacao               64-65 /// v15
      Deflator_fator                     66-70 /// v16
      Valor_da_despesa_deflacionado      71-81 /// v17
      Despesa_anualizada_e_expandido     82-97 /// v18
      Codigo_de_imputacao                98-99 /// v19
      Renda_monetaria_mensal_da_UC     100-115 /// v20
      Renda_nao_monetaria_mensal_da_UC 116-131 /// v21
      Renda_total_mensal_da_UC         132-147 /// v22
      Metodo_da_quantidade_adquirida   148-149 /// v23
      Quantidade_final_em_kg           150-157 /// v24
      Codigo_do_local_de_aquisicao     158-162 /// v25
      Quantidade_do_item               163-172 /// v26
      Codigo_da_unidade_de_medida      173-177 /// v27
      Codigo_do_peso_ou_volume         178-182 using T_CADERNETA_DESPESA_S.txt

save "11_CADERNETA_DESPESA.dta"
