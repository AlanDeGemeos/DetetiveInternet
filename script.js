
const botao = document.getElementById("iniciar-teste");
const baixar = document.getElementById("baixar-relatorio");
const resultados = document.getElementById("resultados");
const estado = document.getElementById("estado");
const indicador = document.getElementById("indicador");
const barra = document.getElementById("barra-progresso");
const progresso = document.getElementById("progresso-texto");

const TOTAL_TESTES = 20;
const LIMITE_TEMPO = 5000;

let ultimoRelatorio = "";

function arredondar(numero) {
    return Number(numero.toFixed(2));
}

function atualizarStatus(texto, classe = "") {
    estado.textContent = texto;
    indicador.className = "indicador " + classe;
}

function calcularEstatisticas(tempos) {
    if (tempos.length === 0) {
        return null;
    }

    const menor = Math.min(...tempos);
    const maior = Math.max(...tempos);

    const media = tempos.reduce(
        (soma, valor) => soma + valor, 0
    ) / tempos.length;

    const variacoes = [];

    for (let i = 1; i < tempos.length; i++) {
        variacoes.push(
            Math.abs(tempos[i] - tempos[i - 1])
        );
    }

    const variacaoMedia = variacoes.length
        ? variacoes.reduce((a, b) => a + b, 0)
        / variacoes.length
        : 0;

    return {
        menor: arredondar(menor),
        maior: arredondar(maior),
        media: arredondar(media),
        variacaoMedia: arredondar(variacaoMedia),
        amplitude: arredondar(maior - menor)
    };
}

function classificar(falhas, estatisticas) {
    if (!estatisticas) {
        return "RUIM";
    }

    const percentualFalhas = falhas / TOTAL_TESTES * 100;

    if (
        percentualFalhas > 10 ||
        estatisticas.variacaoMedia > 150
    ) {
        return "RUIM";
    }

    if (
        percentualFalhas > 0 ||
        estatisticas.variacaoMedia > 50
    ) {
        return "REGULAR";
    }

    return "BOM";
}

function gerarOrientacoes(falhas, estatisticas) {
    const orientacoes = [];

    if (falhas > 0) {
        orientacoes.push(
            "- Verifique se o Wi-Fi está oscilando. " +
            "Repita o teste próximo ao roteador."
        );

        orientacoes.push(
            "- Se possível, compare com uma conexão " +
            "por cabo e verifique os equipamentos."
        );

        orientacoes.push(
            "- Verifique também se o servidor de teste " +
            "está acessível por outra conexão."
        );
    }

    if (
        estatisticas &&
        estatisticas.variacaoMedia > 50
    ) {
        orientacoes.push(
            "- Foram observadas oscilações nos tempos HTTP. " +
            "Verifique a intensidade do Wi-Fi e possíveis " +
            "interferências."
        );

        orientacoes.push(
            "- Repita o teste sem downloads ou outras " +
            "atividades intensas na rede."
        );
    }

    if (estatisticas && estatisticas.maior > 1000) {
        orientacoes.push(
            "- Houve uma requisição demorada. " +
            "Verifique se a lentidão se repete " +
            "em outros serviços."
        );
    }

    if (orientacoes.length === 0) {
        orientacoes.push(
            "- Nenhuma anormalidade foi identificada " +
            "pelos critérios deste teste HTTP."
        );

        orientacoes.push(
            "- Se o cliente ainda relatar problemas, " +
            "investigue Wi-Fi, roteador e conexão do provedor."
        );
    }

    return orientacoes.join("\n");
}

async function testarRequisicao() {
    const inicio = performance.now();

    // O parâmetro evita reutilizar uma resposta em cache.
    const url =
        "https://www.google.com/favicon.ico?t=" +
        Date.now() + "-" + Math.random();

    await fetch(url, {
        mode: "no-cors",
        cache: "no-store",
        signal: AbortSignal.timeout(LIMITE_TEMPO)
    });

    return arredondar(performance.now() - inicio);
}

function informacoesConexao() {
    const conexao =
        navigator.connection ||
        navigator.mozConnection ||
        navigator.webkitConnection;

    if (!conexao) {
        return "Informações não disponíveis neste navegador.";
    }

    return [
        `Tipo informado: ${conexao.effectiveType || "Indisponível"}`,
        `Velocidade estimada pelo navegador: ${conexao.downlink ?? "Indisponível"
        } Mbps`,
        `RTT estimado pelo navegador: ${conexao.rtt ?? "Indisponível"
        } ms`
    ].join("\n");
}

function formatarEstatisticas(dados) {
    if (!dados) {
        return "Não há medições suficientes.";
    }

    return [
        `Menor tempo: ${dados.menor} ms`,
        `Maior tempo: ${dados.maior} ms`,
        `Tempo médio: ${dados.media} ms`,
        `Amplitude: ${dados.amplitude} ms`,
        `Variação média: ${dados.variacaoMedia} ms`
    ].join("\n");
}

async function iniciarDiagnostico() {
    botao.disabled = true;
    baixar.disabled = true;

    botao.textContent = "Investigando...";
    resultados.textContent = "Preparando testes...";

    barra.style.width = "0%";
    atualizarStatus("Diagnóstico em andamento");

    ultimoRelatorio = "";

    const tempos = [];
    const detalhes = [];

    let sucessos = 0;
    let falhas = 0;

    const onlineInicial = navigator.onLine;
    const inicioGeral = performance.now();

    try {
        for (let i = 1; i <= TOTAL_TESTES; i++) {
            progresso.textContent =
                `Executando requisição ${i} de ${TOTAL_TESTES}`;

            try {
                const tempo = await testarRequisicao();

                tempos.push(tempo);
                sucessos++;

                detalhes.push(
                    `Teste ${i}: concluído em ${tempo} ms`
                );

            } catch (erro) {
                falhas++;

                detalhes.push(
                    `Teste ${i}: falha ou tempo limite`
                );
            }

            const percentual = i / TOTAL_TESTES * 100;
            barra.style.width = `${percentual}%`;

            resultados.textContent =
                detalhes.join("\n");
        }

        const duracao = arredondar(
            (performance.now() - inicioGeral) / 1000
        );

        const estatisticas = calcularEstatisticas(tempos);
        const classificacao = classificar(
            falhas, estatisticas
        );

        const percentualFalhas = arredondar(
            falhas / TOTAL_TESTES * 100
        );

        const orientacoes = gerarOrientacoes(
            falhas, estatisticas
        );

        const relatorio = [
            "================================",
            "       DETETIVE DE INTERNET",
            "================================",
            "",
            "DIAGNÓSTICO DE CONEXÃO HTTP",
            "",
            "TESTE 1 - ESTADO DO NAVEGADOR",
            `Estado inicial: ${onlineInicial ? "Online informado" : "Offline informado"
            }`,
            `Estado final: ${navigator.onLine ? "Online informado" : "Offline informado"
            }`,
            "",
            "TESTE 2 - REQUISIÇÕES HTTP",
            `Total: ${TOTAL_TESTES}`,
            `Concluídas: ${sucessos}`,
            `Falhas: ${falhas}`,
            `Percentual de falhas: ${percentualFalhas}%`,
            "",
            "TESTE 3 - TEMPOS DE RESPOSTA HTTP",
            formatarEstatisticas(estatisticas),
            "",
            "TESTE 4 - INFORMAÇÕES DO NAVEGADOR",
            informacoesConexao(),
            "",
            "TESTE 5 - ESTABILIDADE HTTP",
            `Classificação experimental: ${classificacao}`,
            `Duração do diagnóstico: ${duracao} segundos`,
            "",
            "RESULTADOS INDIVIDUAIS",
            ...detalhes,
            "",
            "ORIENTAÇÕES AO TÉCNICO",
            orientacoes,
            "",
            "OBSERVAÇÕES IMPORTANTES",
            "Este teste não mede ping ICMP,",
            "perda real de pacotes ou velocidade real.",
            "Requisições no-cors não permitem",
            "verificar o status HTTP da resposta.",
            "As falhas podem envolver navegador,",
            "servidor remoto ou conexão local.",
            "Os limites de classificação são",
            "experimentais e não são um padrão técnico.",
            "",
            "Nenhuma identificação de cliente é coletada.",
            "================================"
        ];

        ultimoRelatorio = relatorio.join("\n");
        resultados.textContent = ultimoRelatorio;

        atualizarStatus(
            `Diagnóstico concluído: ${classificacao}`,
            classificacao.toLowerCase()
        );

        progresso.textContent =
            "20 requisições processadas.";

        baixar.disabled = false;

    } catch (erro) {
        atualizarStatus("Erro no diagnóstico", "ruim");

        resultados.textContent =
            "Ocorreu um erro inesperado: " + erro.message;

    } finally {
        botao.disabled = false;
        botao.textContent = "Iniciar novo diagnóstico";
    }
}

function baixarRelatorio() {
    if (!ultimoRelatorio) {
        return;
    }

    const arquivo = new Blob(
        [ultimoRelatorio],
        { type: "text/plain;charset=utf-8" }
    );

    const endereco = URL.createObjectURL(arquivo);
    const link = document.createElement("a");

    link.href = endereco;
    link.download = "relatorio-detetive-internet.txt";

    document.body.appendChild(link);
    link.click();
    link.remove();

    URL.revokeObjectURL(endereco);
}

botao.addEventListener("click", iniciarDiagnostico);
baixar.addEventListener("click", baixarRelatorio);
