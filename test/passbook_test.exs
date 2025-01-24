defmodule PassbookTest do
  use ExUnit.Case
  doctest Passbook

  setup_all do
    # Get absolute paths
    project_dir = File.cwd!()
    fixtures_dir = Path.join(project_dir, "test/fixtures")
    scripts_dir = Path.join(project_dir, "scripts")

    # Ensure fixtures directory exists
    File.mkdir_p!(fixtures_dir)

    # Choose script based on OS
    {script, command, args} =
      case :os.type() do
        {:win32, _} ->
          script = Path.join(scripts_dir, "generate_test_fixtures.bat")
          {script, "cmd", ["/c", script]}

        _ ->
          script = Path.join(scripts_dir, "generate_test_fixtures.sh")
          {script, "sh", [script]}
      end

    # Ensure script is executable
    File.chmod!(script, 0o755)

    # Run the script
    case System.cmd(command, args, stderr_to_stdout: true) do
      {_output, _code} ->
        :ok
    end

    on_exit(fn ->
      # Clean up generated test files after all tests complete
      File.rm_rf!(fixtures_dir)
    end)

    :ok
  end

  # Additional tests can be added here
end
