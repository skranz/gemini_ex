## Gemini API via Github Actions

- Fork this repo

- Sign up to Google AI Studio (https://aistudio.google.com/) and get a Gemini API Key.

- Set the Gemini API Key as the Github Action repository secret with name `API_KEY`. To set the secret go to your fork of this repo and then on Github 

`Settings -> Secrets and Variables -> Actions -> Repository Secrets`

- Now you can copy all the prompts you want to ask as separate `.txt` files into the `prompts` of your forked repo. 

- You can also adapt the `.yml` configuration files in the `config` folder.

- To start the workflow that calls Gemini with the prompts go on the Github page of your repository to:

`Actions -> Run Test Workflow -> Run Workflow`

- After the workflow has successfully finished, press on the workflow run, scroll down and you find under`Artifacts` the ZIP file `gemini_results` that can be downloaded. It contains the Gemini results as an R `Rds` file.

- To automate the steps, look at Github's command line client https://cli.github.com/ or also at https://repboxr.r-universe.dev/GithubActions

NOTE: Rate limits might apply and analysis may fail if to quickly too many requests or too large requests are send to Gemini.


