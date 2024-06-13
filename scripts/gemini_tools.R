escape_quotes = function(txt, double_quotes=TRUE, single_quotes=TRUE) {
  if (single_quotes) {
    txt = gsub("'","\\'",txt, fixed=TRUE)
  }
  if (double_quotes) {
    txt = gsub('"','\\"',txt, fixed=TRUE)
  }
  txt
}

example = function() {
  cat(gemini_curl_cmd("Tell a 'joke'","my_key",json_mode = TRUE))
  run_gemini("Tell a joke.","my_key",json_mode = TRUE)
}

example = function() {
  res = readRDS("C:/libraries/gpt/gemini/result.Rds")
  df = gemini_result_to_df(res, artid="myart")
}

gemini_result_to_df = function(res, ...) {

  if (!is.null(res$error)) {
    li = c(
      list(...),
      res[c("model","json_mode","temperature")],
      list(
        error = res$error$message,
        finishReason = "error",
        content = NA
      )
    )
  } else {
    li = c(
      list(...),
      res[c("model","json_mode","temperature")],
      list(
        error = "",
        finishReason = res$candidates$finishReason[1],
        content = paste0(unlist(res$candidates$content,use.names = FALSE), collapse="")
      )
    )
  }
  return(as.data.frame(li))

}

run_gemini = function(prompt,api_key, model="gemini-1.5-flash", json_mode=FALSE, temperature=0.1, add_prompt=FALSE, verbose=TRUE) {
  library(httr)
  library(jsonlite)

  url = paste0("https://generativelanguage.googleapis.com/v1beta/models/", model,":generateContent?key=", api_key)

  generationConfig = list(
    temperature = temperature
  )
  if (json_mode) {
    generationConfig$response_mime_type = "application/json"
  }


  response <- POST(
    url = paste0("https://generativelanguage.googleapis.com/v1beta/models/", model,":generateContent"),
    query = list(key = api_key),
    content_type_json(),
    encode = "json",
    body = list(
      contents = list(
        parts = list(
          list(text = prompt)
        )
      ),
      generationConfig = generationConfig
    )
  )

  # Check the status code of the response
  status_code = status_code(response)

  # Output the content of the response
  json = content(response, "text")

  if (verbose) {
    cat("\n\nResult:\n",nchar(json), " characters:\n\n",json)
  }
  library(jsonlite)
  res = try(fromJSON(json),silent = TRUE)
  if (is(res, "try-error")) {
    res = list(status_code = status_code,parse_error=TRUE, json=json)
    return(res)
  }
  res$status_code = status_code
  res$parse_error = FALSE
  if (add_prompt) {
    res$prompt = prompt
  }
  res$model = model
  res$json_mode = json_mode
  res$temperature = temperature
  res

}


run_gemini_embedding = function(text,api_key, model="gemini-1.5-flash",  add_text=FALSE, verbose=TRUE) {
  library(httr)
  library(jsonlite)

  cat("\nCreate embedding:\n")

  response <- POST(
    url = paste0("https://generativelanguage.googleapis.com/v1beta/models/", model,":generateEmbeddings"),
    query = list(key = api_key),
    content_type_json(),
    encode = "json",
    body = list(
      contents = list(
        text = list(text=text)
      )
    )
  )

  # Check the status code of the response
  status_code = status_code(response)

  library(jsonlite)
  #cat("\nResponse from creating embedding:\n")

  #cat(jsonlite::toJSON(response))

  # Output the content of the response
  json = content(response, "text")

  if (verbose) {
    cat("\n\nResult:\n",nchar(json), " characters:\n\n",json)
  }
  library(jsonlite)
  res = try(fromJSON(json),silent = TRUE)
  if (is(res, "try-error")) {
    res = list(status_code = status_code,parse_error=TRUE, json=json)
    return(res)
  }
  res$status_code = status_code
  res$parse_error = FALSE
  if (add_prompt) {
    res$prompt = prompt
  }
  res$model = model
  res$json_mode = json_mode
  res$temperature = temperature
  res

}
