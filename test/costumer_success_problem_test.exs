defmodule CostumerSuccessProblemTest do
  use ExUnit.Case, async: false

  setup do
    :ok
  end

  setup [:cria_costumer_success, :cria_costumer_success_clientes]

  test "Deve preencher uma lista com 5 costumer success", %{lista_cs: lista_cs} do
    assert lista_cs != nil
    assert Enum.count(lista_cs) == 5
  end

  test "Deve preencher uma lista com 10 clientes que são atendidos pelos costumer success", %{lista_clientes_cs: lista_clientes_cs} do
    assert lista_clientes_cs != nil
    assert Enum.count(lista_clientes_cs) == 10
  end
  
  test "Deve atender apenas clientes menor ou igual ao seu nivel", %{lista_clientes_cs: lista_clientes_cs}  do
    cs_nivel_20 = %CostumerSuccess{id: 1, descricao: "CS 1", nivel_atendimento: 20}
    
    clientes_atendidos = GerenciaAtendimentoCs.selecionar_clientes_para_atendimento(cs_nivel_20, lista_clientes_cs)
    assert Enum.count(clientes_atendidos) == 2
  end     

  test "Deve retornar lista vazia quando não estiver apto a atender alguém da lista de clientes", %{lista_clientes_cs: lista_clientes_cs} do
    cs_nivel_sem_nivel = %CostumerSuccess{id: 1, descricao: "CS 1", nivel_atendimento: 0}

    clientes_atendidos = GerenciaAtendimentoCs.selecionar_clientes_para_atendimento(cs_nivel_sem_nivel, lista_clientes_cs)
    assert Enum.empty?(clientes_atendidos)  
  end

  test "Deve atualizar os clientes possíveis de atendimento ao retirar um Costumer Success", %{lista_cs: lista_cs, lista_clientes_cs: lista_clientes_cs} do
    lista_ordenada = GerenciaAtendimentoCs.ordena_clientes_para_atendimento(lista_cs, lista_clientes_cs)
    expected_result = [
                        [%CostumerSuccessClient{id: 1, nivel: 10}, %CostumerSuccessClient{id: 2, nivel: 20}], 
                        [%CostumerSuccessClient{id: 3, nivel: 30}, %CostumerSuccessClient{id: 4, nivel: 40}], 
                        [%CostumerSuccessClient{id: 5, nivel: 50}, %CostumerSuccessClient{id: 7, nivel: 60}], 
                        [%CostumerSuccessClient{id: 6, nivel: 70}, %CostumerSuccessClient{id: 9, nivel: 80}], 
                        [%CostumerSuccessClient{id: 8, nivel: 90}, %CostumerSuccessClient{id: 10, nivel: 100}]
                      ]
    
    assert lista_ordenada == expected_result
  end

  test "Deve mostrar que o CS de nível de atendimento 60 também atende os clientes do CS de nível 40 quando o mesmo estiver ausente", %{lista_cs: lista_cs, lista_clientes_cs: lista_clientes_cs} do
    lista_cs_sem_nivel_atendimento_40 = Enum.reject(lista_cs, fn x -> x.nivel_atendimento == 40 end) 
    lista_clientes = GerenciaAtendimentoCs.ordena_clientes_para_atendimento(lista_cs_sem_nivel_atendimento_40, lista_clientes_cs)
    
    expected_result = [
      [%CostumerSuccessClient{id: 1, nivel: 10}, %CostumerSuccessClient{id: 2, nivel: 20}],  
      [%CostumerSuccessClient{id: 3, nivel: 30}, %CostumerSuccessClient{id: 4, nivel: 40},
        %CostumerSuccessClient{id: 5, nivel: 50}, %CostumerSuccessClient{id: 7, nivel: 60}], 
      [%CostumerSuccessClient{id: 6, nivel: 70}, %CostumerSuccessClient{id: 9, nivel: 80}], 
      [%CostumerSuccessClient{id: 8, nivel: 90}, %CostumerSuccessClient{id: 10, nivel: 100}]
    ]

    assert expected_result == lista_clientes
  end

  test "Deve mostrar uma lista com os clientes só até o nível 40 quando tiver customer success com nível de atendimento 20 e 40", %{lista_cs: lista_cs, lista_clientes_cs: lista_clientes_cs} do
    lista_cs_com_nivel_atendimento_menor_igual_40 = Enum.reject(lista_cs, fn x -> x.nivel_atendimento > 40 end)

    lista_clientes = GerenciaAtendimentoCs.ordena_clientes_para_atendimento(lista_cs_com_nivel_atendimento_menor_igual_40, lista_clientes_cs)

    expected_result = [
      [%CostumerSuccessClient{id: 1, nivel: 10}, %CostumerSuccessClient{id: 2, nivel: 20}],  
      [%CostumerSuccessClient{id: 3, nivel: 30}, %CostumerSuccessClient{id: 4, nivel: 40}]
    ]

    assert expected_result == lista_clientes
  end

  test "Deve mostrar lista com todos os clientes quando tiver só o customer success com nível de atendimento 100", %{lista_cs: lista_cs, lista_clientes_cs: lista_clientes_cs} do
      lista_cs_somente_com_nivel_atendimento_100 = Enum.reject(lista_cs, fn x -> x.nivel_atendimento < 100 end)
      
      lista_clientes = GerenciaAtendimentoCs.ordena_clientes_para_atendimento(lista_cs_somente_com_nivel_atendimento_100, lista_clientes_cs)
      
      expected_result = [
                         [%CostumerSuccessClient{id: 1, nivel: 10}, %CostumerSuccessClient{id: 2, nivel: 20},  
                          %CostumerSuccessClient{id: 3, nivel: 30}, %CostumerSuccessClient{id: 4, nivel: 40},
                          %CostumerSuccessClient{id: 5, nivel: 50}, %CostumerSuccessClient{id: 7, nivel: 60}, 
                          %CostumerSuccessClient{id: 6, nivel: 70}, %CostumerSuccessClient{id: 9, nivel: 80}, 
                          %CostumerSuccessClient{id: 8, nivel: 90}, %CostumerSuccessClient{id: 10, nivel: 100}]
                      ]
      
      assert expected_result == lista_clientes
  end

  defp cria_costumer_success(_) do
    lista_cs = [
      %CostumerSuccess{id: 1, descricao: "CS 1", nivel_atendimento: 20},
      %CostumerSuccess{id: 2, descricao: "CS 2", nivel_atendimento: 40},
      %CostumerSuccess{id: 3, descricao: "CS 3", nivel_atendimento: 60},
      %CostumerSuccess{id: 4, descricao: "CS 4", nivel_atendimento: 80},
      %CostumerSuccess{id: 5, descricao: "CS 5", nivel_atendimento: 100},
    ]

    {:ok, lista_cs: lista_cs}
  end

  defp cria_costumer_success_clientes(_) do
    lista_clientes_cs = [
      %CostumerSuccessClient{ id: 1, nivel: 10},
      %CostumerSuccessClient{ id: 2, nivel: 20},
      %CostumerSuccessClient{ id: 3, nivel: 30},
      %CostumerSuccessClient{ id: 4, nivel: 40},
      %CostumerSuccessClient{ id: 5, nivel: 50},
      %CostumerSuccessClient{ id: 6, nivel: 70},
      %CostumerSuccessClient{ id: 7, nivel: 60},
      %CostumerSuccessClient{ id: 8, nivel: 90},
      %CostumerSuccessClient{ id: 9, nivel: 80},
      %CostumerSuccessClient{ id: 10, nivel: 100},
    ]

    {:ok, lista_clientes_cs: lista_clientes_cs}
  end
end