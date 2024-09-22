defmodule Marvel.Test.MockHelpers do
  import Mox

  @http_client Marvel.HTTPClientMock

  def mock_successful_response(type) do
    {resp, _} = Code.eval_file("test/support/fixtures/#{type}.exs")

    expect(
      @http_client,
      :get,
      fn _url ->
        {:ok, %HTTPoison.Response{body: resp |> Jason.encode!(), status_code: 200}}
      end
    )

    resp
  end

  def mock_not_found_response() do
    resp = %{"code" => 404, "status" => "We couldn't find that <object>"}

    expect(
      @http_client,
      :get,
      6,
      fn _url ->
        {:ok, %HTTPoison.Response{status_code: 404, body: resp |> Jason.encode!()}}
      end
    )

    resp
  end
end
