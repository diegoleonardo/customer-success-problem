defmodule GerenciaAtendimentoCs do 
  
  def selecionar_clientes_para_atendimento(cs, clientes) when is_list(clientes) do
    Enum.filter(clientes, fn x -> x.nivel <= cs.nivel_atendimento end)
  end

  def ordena_clientes_para_atendimento(lista_cs, lista_clientes) when is_list(lista_cs) and is_list(lista_clientes) do
    lista_cs_ordenada = Enum.sort(lista_cs, &(&1.nivel_atendimento <= &2.nivel_atendimento)) 
    
    cs_que_atende_menor_nivel = Enum.min_by(lista_cs, fn x -> x.nivel_atendimento end)

    ordena_clientes_para_atendimento(lista_cs_ordenada, lista_clientes, cs_que_atende_menor_nivel)
  end

  defp ordena_clientes_para_atendimento(lista_cs, lista_clientes, cs_que_atende_menor_nivel) when is_list(lista_cs) and is_list(lista_clientes) do
    Enum.map(lista_cs, fn x ->
                          cond do
                            cs_que_atende_menor_nivel.nivel_atendimento == x.nivel_atendimento -> 
                                selecionar_clientes_para_atendimento(x, lista_clientes)
                              
                            true -> 
                                customer_success_anterior = Enum.filter(lista_cs, fn z -> z.nivel_atendimento < x.nivel_atendimento end) 
                                                              |> List.last()

                                selecionar_clientes_para_atendimento(x, lista_clientes)
                                    |> Enum.filter(fn y -> y.nivel > customer_success_anterior.nivel_atendimento end)
                          end
    end)
  end
end