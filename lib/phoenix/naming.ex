defmodule Phoenix.Naming do
  @moduledoc """
  Conveniences for inflecting and working with names in Phoenix.
  """

  @doc """
  Extracts the resource name from an alias.

  ## Examples

      iex> Phoenix.Naming.resource_name(MyApp.User)
      "user"

      iex> Phoenix.Naming.resource_name(MyApp.UserView, "View")
      "user"

  """
  @spec resource_name(String.Chars.t, String.t) :: String.t
  def resource_name(alias, suffix \\ "") do
    alias
    |> to_string()
    |> Module.split()
    |> List.last()
    |> unsuffix(suffix)
    |> underscore()
  end

  @doc """
  Removes the given suffix from the name if it exists.

  ## Examples

      iex> Phoenix.Naming.unsuffix("MyApp.User", "View")
      "MyApp.User"

      iex> Phoenix.Naming.unsuffix("MyApp.UserView", "View")
      "MyApp.User"

  """
  @spec unsuffix(String.Chars.t, String.t) :: String.t
  def unsuffix(value, "") do
    to_string(value)
  end

  def unsuffix(value, suffix) do
    string = to_string(value)
    suffix_size = byte_size(suffix)
    prefix_size = byte_size(string) - suffix_size
    case string do
      <<prefix::binary-size(prefix_size), ^suffix::binary>> -> prefix
      _ -> string
    end
  end

  @doc """
  Finds the Base Namespace of the module with optional concat

  ## Examples

      iex> Phoenix.Naming.base_concat(MyApp.MyChannel)
      MyApp

      iex> Phoenix.Naming.base_concat(MyApp.Admin.MyChannel, PubSub)
      MyApp.PubSub

      iex> Phoenix.Naming.base_concat(MyApp.Admin.MyChannel, "PubSub")
      MyApp.PubSub

  """
  def base_concat(mod, submodule \\ nil) do
    mod
    |> Module.split
    |> hd
    |> Module.concat(submodule)
  end

  @doc """
  Converts String to underscore case.

  ## Examples

      iex> Phoenix.Naming.underscore("MyApp")
      "my_app"

      iex> Phoenix.Naming.underscore(:MyApp)
      "my_app"

      iex> Phoenix.Naming.underscore("my-app")
      "my_app"

  In general, `underscore` can be thought of as the reverse of
  `camelize`, however, in some cases formatting may be lost:

      Phoenix.Naming.underscore "SAPExample"  #=> "sap_example"
      Phoenix.Naming.camelize   "sap_example" #=> "SapExample"

  """
  @spec underscore(String.Chars.t) :: String.t

  def underscore(value) when not is_binary(value) do
    underscore(to_string(value))
  end

  def underscore(""), do: ""

  def underscore(<<h, t :: binary>>) do
    <<to_lower_char(h)>> <> do_underscore(t, h)
  end

  defp do_underscore(<<h, t, rest :: binary>>, _) when h in ?A..?Z and not t in ?A..?Z do
    <<?_, to_lower_char(h), t>> <> do_underscore(rest, t)
  end

  defp do_underscore(<<h, t :: binary>>, prev) when h in ?A..?Z and not prev in ?A..?Z do
    <<?_, to_lower_char(h)>> <> do_underscore(t, h)
  end

  defp do_underscore(<<?-, t :: binary>>, _) do
    <<?_>> <> do_underscore(t, ?-)
  end

  defp do_underscore(<< "..", t :: binary>>, _) do
    <<"..">> <> underscore(t)
  end

  defp do_underscore(<<?.>>, _), do: <<?.>>

  defp do_underscore(<<?., t :: binary>>, _) do
    <<?/>> <> underscore(t)
  end

  defp do_underscore(<<h, t :: binary>>, _) do
    <<to_lower_char(h)>> <> do_underscore(t, h)
  end

  defp do_underscore(<<>>, _) do
    <<>>
  end

  defp to_lower_char(char) when char in ?A..?Z, do: char + 32
  defp to_lower_char(char), do: char

  @doc """
  Converts String to camel case.

  ## Examples

      iex> Phoenix.Naming.camelize("my_app")
      "MyApp"

      iex> Phoenix.Naming.camelize(:my_app)
      "MyApp"

  In general, `camelize` can be thought of as the reverse of
  `underscore`, however, in some cases formatting may be lost:

      Phoenix.Naming.underscore "SAPExample"  #=> "sap_example"
      Phoenix.Naming.camelize   "sap_example" #=> "SapExample"

  """
  @spec camelize(String.Chars.t) :: String.t

  def camelize(value) when not is_binary(value) do
    camelize(to_string(value))
  end

  def camelize(""), do: ""

  def camelize(<<?_, t :: binary>>) do
    camelize(t)
  end

  def camelize(<<h, t :: binary>>) do
    <<to_upper_char(h)>> <> do_camelize(t)
  end

  defp do_camelize(<<?_, ?_, t :: binary>>) do
    do_camelize(<< ?_, t :: binary >>)
  end

  defp do_camelize(<<?_, h, t :: binary>>) when h in ?a..?z do
    <<to_upper_char(h)>> <> do_camelize(t)
  end

  defp do_camelize(<<?_>>) do
    <<>>
  end

  defp do_camelize(<<?/, t :: binary>>) do
    <<?.>> <> camelize(t)
  end

  defp do_camelize(<<h, t :: binary>>) do
    <<h>> <> do_camelize(t)
  end

  defp do_camelize(<<>>) do
    <<>>
  end

  defp to_upper_char(char) when char in ?a..?z, do: char - 32
  defp to_upper_char(char), do: char
end
