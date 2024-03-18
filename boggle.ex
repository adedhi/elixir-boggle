defmodule Boggle do
  @moduledoc """
    Add your boggle function below. You may add additional helper functions if you desire.
    Test your code by running 'mix test' from the tester_ex_simple directory.
  """

  def getNeighbors(i, j, board_size) do
    possible_neighbors =
      for a <- [-1, 0, 1], b <- [-1, 0, 1], {a, b} != {0, 0},
          new_i = i + a,
          new_j = j + b,
          new_i >= 0 and new_i < board_size and new_j >= 0 and new_j < board_size do
        {new_i, new_j}
      end
    possible_neighbors
  end

  def getValidNeighbors(i, j, board, next_char, visited_points, board_size) do
    Enum.filter(getNeighbors(i, j, board_size), fn {new_i, new_j} ->
      (elem (elem board, new_i), new_j) == next_char and
      not MapSet.member?(visited_points, {new_i, new_j})
    end)
  end

  def findWord([], _board, _point, _visited_points, points_list, _board_size) do
    Enum.reverse(points_list)
  end

  def findWord([next_char | next_word], board, {i, j}, visited_points, points_list, board_size) do
    valid_neighbors = getValidNeighbors(i, j, board, next_char, visited_points, board_size)
    Enum.reduce(valid_neighbors, false, fn {new_i, new_j}, acc ->
      if acc, do: acc, else: findWord(next_word, board, {new_i, new_j}, MapSet.put(visited_points, {new_i, new_j}), [{new_i, new_j} | points_list], board_size)
    end)
  end

  def searchForWords([], new_dict_arr, _board, _i, _j, found_dict, _board_size) do
    {new_dict_arr, found_dict}
  end

  def searchForWords(dict_arr, new_dict_arr, board, i, j, found_dict, board_size) do
      search_result = findWord((tl (hd dict_arr)), board, {i, j}, MapSet.new([{i, j}]), [{i, j}], board_size)
      if (is_list(search_result)) do
        searchForWords((tl dict_arr), new_dict_arr, board, i, j, (Map.put(found_dict, (hd dict_arr), search_result)), board_size)
      else
        searchForWords((tl dict_arr), ([(hd dict_arr) | new_dict_arr]), board, i, j, found_dict, board_size)
      end
  end

  def searchBoard(_word_dict, _board, i, _j, found_dict, board_size) when i >= board_size,
    do: found_dict

  def searchBoard(word_dict, board, i, j, found_dict, board_size) when j >= board_size,
    do: searchBoard(word_dict, board, (i + 1), 0, found_dict, board_size)

  def searchBoard(word_dict, board, i, j, found_dict, board_size) do
    curr_char = (elem (elem board, i), j)
    if ((Map.has_key?(word_dict, curr_char))) do
      {new_dict_arr, new_found_dict} = (searchForWords(Map.get(word_dict, curr_char), [], board, i, j, found_dict, board_size))
      searchBoard((Map.put(word_dict, curr_char, new_dict_arr)), board, i, (j + 1), new_found_dict, board_size)
    else
      searchBoard(word_dict, board, i, (j + 1), found_dict, board_size)
    end
  end

  def boggle(board, words) do
    board_size = (tuple_size(board))
    board_full_size = (board_size * board_size)

    valid_words = Enum.filter(words, fn word ->
      String.length(word) <= board_full_size
    end)

    word_dict = Enum.reduce(valid_words, %{}, fn string, acc ->
      key = String.first(string)
      Map.update(acc, key, [String.graphemes(string)], fn current_value -> [String.graphemes(string) | current_value] end)
    end)

    found_dict = searchBoard(word_dict, board, 0, 0, %{}, board_size)

    return_dict = Enum.map(found_dict, fn {key, value} ->
      {List.to_string(key), value}
    end)

    Enum.into(return_dict, %{})
  end
end
