perform_analysis = function() {
  library(dplyr)
  API_KEY = Sys.getenv("API_KEY")
  setwd("~")
  outdir = "/root/output"
  if (.Platform$OS.type == "windows") {
    setwd("C:/libraries/gpt/gemini/gemini_ex")
  }
  if (FALSE) {
    setwd("~/repbox/gemini/gemini_gha")
  }

  source("scripts/gemini_tools.R")

  config_df = load_prompt_configs()

  prompt_files = list.files("prompts", glob2rx("*.txt"),full.names = TRUE)
  file = first(prompt_files)

  for (file in prompt_files) {
    prompt_name = tools::file_path_sans_ext(basename(file))
    cat("\n\n****", prompt_name, "***\n")
    res = analyse_prompt_file(file, config_df=config_df, api_key = API_KEY)
    out_file = paste0(outdir, "/", prompt_name,".Rds")
    saveRDS(res, out_file)
  }

  cat("\n\nFINISHED\n\n")
}


analyse_prompt_file = function(file, config_df,  api_key,verbose=TRUE, add_prompt=TRUE){
  if (verbose) {
    cat(paste0("\n\nANALYSE ", file,"\n\n"))
  }
  prompt = paste0(readLines(file,warn = FALSE), collapse="\n")
  config = get_prompt_config(file, config_df)

  prompt_name = tools::file_path_sans_ext(basename(file))

  if (isTRUE(config$embedding)) {
    res = run_gemini_embedding(prompt, api_key,  model=config$model)
  } else {
    res = run_gemini(prompt, api_key, json_mode=config$json_mode, model=config$model, temperature = config$temperature)
  }

  res$prompt_name = prompt_name
  if (isTRUE(config$add_prompt)) {
    res$prompt = prompt
  }
  res
}

get_prompt_config = function(file, config_df) {
  def_config = config_df[config_df$prompt_type=="_default",]
  prompt_id = tools::file_path_sans_ext(basename(file))
  row = which(prompt_id==config_df$prompt_type)
  if (length(row)==0) {
    row = which(startsWith(prompt_id, config_df$prompt_type))
  }
  if (length(row)==0) return(def_config)
  config = config_df[row[1],]
  fields = names(config)
  fields = fields[!sapply(config,is.na)]
  def_config[1, fields] = config[1, fields]
  def_config[1,]
}

load_prompt_configs = function() {
  library(stringi)
  library(dplyr)

  files = list.files("config",glob2rx("*.yml"),full.names = TRUE)
  config_df = bind_rows(lapply(files, function(config_file) {
    res = yaml::yaml.load_file(config_file)
    prompt_type = tools::file_path_sans_ext(basename(config_file))
    res$prompt_type = prompt_type
    res = as.data.frame(res)
  }))
  return(config_df)
}

