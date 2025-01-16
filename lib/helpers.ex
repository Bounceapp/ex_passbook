defmodule Passbook.Helpers do
  @moduledoc false

  # Camelize atoms in a map
  def camelize(key) when is_atom(key) do
    key |> Atom.to_string() |> camelize
  end

  # Camelize strings in a map
  def camelize(key) when is_binary(key) do
    capitalized = Macro.camelize(key)
    <<first>> <> rest = capitalized
    String.downcase(<<first>>) <> rest
  end

  # if a nested map, camelize the nested map keys
  def camelize({key, value}) when is_map(value) or is_list(value) do
    {camelize(key), camelize(value)}
  end

  # if a list of maps, camelize the maps
  def camelize(map_list) when is_list(map_list) do
    Enum.map(map_list, fn
      %{__struct__: _} = map ->
        map
        |> Map.from_struct()
        |> camelize

      map = %{} ->
        camelize(map)

      any ->
        any
    end)
  end

  # if a map, camelize the keys
  def camelize({key, value}) do
    key = camelize(key)
    {key, value}
  end

  def camelize(%struct{} = datetime) when struct in [DateTime, Ecto.DateTime, NaiveDateTime] do
    datetime
  end

  # if a struct, convert to map and then camelize
  def camelize(%{__struct__: _} = map) do
    map
    |> Map.from_struct()
    |> camelize
  end

  # base camelize function
  def camelize(%{} = map) do
    map
    |> Enum.map(&__MODULE__.camelize/1)
    |> Map.new()
  end

  def create_signature(
        manifest_path,
        signature_path,
        certificate_path,
        key_path,
        wwdr_certificate_path,
        password
      ) do
    case :os.cmd(
           ~c"openssl smime -sign -signer #{certificate_path} -inkey #{key_path} -certfile #{wwdr_certificate_path} -in #{manifest_path} -out #{signature_path} -outform der -binary -passin pass:\"#{password}\""
         ) do
      [] -> :ok
      error -> {:error, error}
    end
  end
end
