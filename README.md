# 🔎 Detetive de Internet

**Ferramenta de diagnóstico de conexões para técnicos de internet.**

O Detetive de Internet é um projeto desenvolvido para auxiliar profissionais de campo na análise de conectividade, identificação de possíveis instabilidades e interpretação de resultados.

Seu principal diferencial é apresentar **orientações práticas para investigação de problemas**, utilizando uma linguagem simples e acessível.

## 🚀 Funcionalidades — Versão Web 1.0

- Verificação experimental de conectividade HTTP.
- Execução de 20 requisições para análise de estabilidade.
- Contagem de requisições concluídas e falhas.
- Medição dos tempos mínimo, máximo e médio de requisição.
- Cálculo da variação média entre os tempos registrados.
- Classificação experimental dos resultados: **BOM, REGULAR ou RUIM**.
- Orientações práticas para auxiliar o técnico.
- Barra de progresso durante o diagnóstico.
- Exportação de relatório em formato `.txt`.
- Interface responsiva para computadores e celulares.

## 🛠️ Tecnologias utilizadas

- **HTML5:** estrutura da interface.
- **CSS3:** estilização e responsividade.
- **JavaScript:** execução dos testes, cálculos e geração de relatórios.
- **Git e GitHub:** versionamento e publicação do projeto.

## 💻 Como executar

1. Clone o repositório:

   `git clone https://github.com/AlanDeGemeos/DetetiveInternet.git`

2. Abra a pasta do projeto no VS Code.
3. Acesse a pasta `app-android`.
4. Abra o arquivo `index.html` utilizando o Live Server.
5. Clique em **Iniciar diagnóstico**.

Não é necessário instalar Node.js ou outras dependências para executar a versão web atual.

## 📊 Interpretação dos resultados

O sistema classifica os resultados de acordo com critérios experimentais baseados em falhas de requisições e variações nos tempos de resposta HTTP.

Esses critérios não representam um padrão oficial de qualidade de conexão.

**Limitações da versão web:**

- Não executa ping ICMP.
- Não mede perda real de pacotes.
- Não realiza um teste confiável de velocidade contratada.
- Não verifica diretamente a comunicação com o roteador.
- Não confirma o código de resposta HTTP das requisições realizadas em modo `no-cors`.

Os resultados devem ser utilizados como informações auxiliares, e não como diagnóstico definitivo da conexão.

## 🔐 Privacidade

O Detetive de Internet foi projetado para realizar testes sem solicitar identificação dos clientes.

A versão web não possui cadastro, autenticação ou banco de dados de clientes. Os testes utilizam requisições a um serviço externo, que pode receber dados técnicos normais da conexão, como o endereço IP público.

## 📁 Versões do projeto

**PowerShell:** implementação original, com testes de rede executados no Windows.

**Web 1.0:** interface desenvolvida com HTML, CSS e JavaScript, voltada à execução de diagnósticos HTTP pelo navegador.

## 🎯 Objetivo

Desenvolver uma ferramenta prática, acessível e de fácil utilização que ajude técnicos de internet a investigar problemas de conectividade de maneira organizada.

---

**Projeto em desenvolvimento — Versão Web 1.0.**