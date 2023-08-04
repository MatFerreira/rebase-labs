# Sobre

Implementação do projeto proposto no programa [Rebase Labs](https://git.campuscode.com.br/-/snippets/18)

## Como executar o projeto

`$ docker compose up`

## Endpoints

+ GET
    - `/`; Página inicial da aplicação. Retorna HTML com um script para consumir `/exams`

    - `/exams?page&limit`; Requer os parâmetros `page` (número da página) e `limit` (quantidade de registros por página). Retorna uma página em JSON no formato:

    ```json
    {
        "data": [
            {
                "exam_result_token": "Z38NEI",
                "exam_date": "2021-05-17",
                "patient_cpf": "099.204.552-53",
                "name": "Ladislau Duarte",
                "email": "lisha@rosenbaum.org",
                "birthdate": "1981-02-02",
                "doctor": {
                    "crm": "B000AR99QO",
                    "crm_state": "MS",
                    "name": "Oliver Palmeira",
                    "email": "lawana.erdman@waters.info"
                },
                "tests": [
                    {
                        "exam_type": "hemácias",
                        "exam_type_limits": "45-52",
                        "exam_type_result": "89"
                    },
                ]
            },
        ],
        "has_next": true
    }
    ```

    - `/exams/:token`; Retorna um exame específico em formato JSON de acordo com o `:token` na URL

+ POST
    - `/import`; Processa arquivos enviados sob a chave `csv_file` e salva os registros no banco de dados da aplicação
