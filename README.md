## Gemini API via Github Actions

- Fork this repo

- Sign up to Google AI Studio (https://aistudio.google.com/) and get a Gemini API Key.

- Set the Gemini API Key as the Github Action repository secret with name `API_KEY`. To set the secret go to your fork of this repo and then on Github 

`Settings -> Secrets and Variables -> Actions -> Repository Secrets`

- Now you can copy all the prompts you want to ask as separate `.txt` files into the `prompts` of your repo. 

- You can also adapt the `.yml` configuration files in the `config` folder.

NOTE: Rate limits might apply. Currently, there is no re-try if a rate limit is hit, but that might be implemented in a future version



