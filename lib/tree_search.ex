defmodule Overwatch.TreeSearch do
  def find_child(tree, key, value) do
    {_, _, children} = tree
    Enum.find(children, fn child ->
      if is_bitstring(child) do
        false
      else
        {_, attrs, _} = child
        attr_value = assoc_list_find(attrs, key, "")
        Enum.member?(String.split(attr_value, " "), value)
      end
    end)
  end

  def find_children(tree, key, value) do
    {_, _, children} = tree
    Enum.filter(children, fn child ->
      if is_bitstring(child) do
        false
      else
        {_, attrs, _} = child
        attr_value = assoc_list_find(attrs, key, "")
        Enum.member?(String.split(attr_value, " "), value)
      end
    end)
  end

  def count_elements(forest) do
    forest_reduce(forest, 0, fn (_el, acc) -> acc + 1 end)
  end

  def forest_reduce(roots, initial_acc, func) do
    Enum.reduce(roots, initial_acc, fn (root, acc) ->
      if is_bitstring(root) do
        acc
      else
        {type, attrs, children} = root
        post_root_acc = func.({type, attrs}, acc)
        forest_reduce(children, post_root_acc, func)
      end
    end)
  end

  defp assoc_list_find(list, target_key, default \\ nil) do
    {_, val} = Enum.find(list, {nil, default}, fn {key, _val} ->
      key == target_key
    end)
    val
  end

end
