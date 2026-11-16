
Clear-Host

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "       DETETIVE DE INTERNET" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Iniciando investigacao da rede..." -ForegroundColor Green
Write-Host ""

Write-Host "TESTE 1 - ROTEADOR" -ForegroundColor Cyan

$gateway = Get-NetIPConfiguration |
Where-Object { $_.IPv4DefaultGateway } |
Select-Object -First 1

if ($gateway) {
    $ipRoteador = $gateway.IPv4DefaultGateway.NextHop

    Write-Host "Roteador encontrado: $ipRoteador" -ForegroundColor Green
}
else {
    Write-Host "Nao foi possivel localizar o roteador." -ForegroundColor Red
}
Write-Host ""
Write-Host "TESTE 2 - COMUNICACAO COM O ROTEADOR" -ForegroundColor Cyan

$respostaRoteador = Test-Connection $ipRoteador -Count 4 -Quiet

if ($respostaRoteador) {
    Write-Host "O roteador esta respondendo!" -ForegroundColor Green
}
else {
    Write-Host "O roteador nao respondeu ao teste." -ForegroundColor Red
}

Write-Host ""
Write-Host "TESTE 3 - CONEXAO COM A INTERNET" -ForegroundColor Cyan

$internet = Test-Connection 1.1.1.1 -Count 4 -Quiet

if ($internet) {
    Write-Host "Existe comunicacao com a internet!" -ForegroundColor Green
}
else {
    Write-Host "Nao foi possivel alcancar a internet." -ForegroundColor Red
}



Clear-Host

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "       DETETIVE DE INTERNET" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Iniciando investigacao da rede..." -ForegroundColor Green
Write-Host ""

Write-Host "TESTE 1 - ROTEADOR" -ForegroundColor Cyan

$gateway = Get-NetIPConfiguration |
Where-Object { $_.IPv4DefaultGateway } |
Select-Object -First 1

if ($gateway) {
    $ipRoteador = $gateway.IPv4DefaultGateway.NextHop
    Write-Host "Roteador encontrado: $ipRoteador" -ForegroundColor Green
}
else {
    Write-Host "Nao foi possivel localizar o roteador." -ForegroundColor Red
}

Write-Host ""
Write-Host "TESTE 2 - COMUNICACAO COM O ROTEADOR" -ForegroundColor Cyan

if ($ipRoteador) {
    $respostaRoteador = Test-Connection $ipRoteador -Count 4 -Quiet

    if ($respostaRoteador) {
        Write-Host "O roteador esta respondendo!" -ForegroundColor Green
    }
    else {
        Write-Host "O roteador nao respondeu ao teste." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "TESTE 3 - CONEXAO COM A INTERNET" -ForegroundColor Cyan

$internet = Test-Connection 1.1.1.1 -Count 4 -Quiet

if ($internet) {
    Write-Host "Existe comunicacao com a internet!" -ForegroundColor Green
}
else {
    Write-Host "Nao foi possivel alcancar a internet." -ForegroundColor Red
}

Write-Host ""
Write-Host "TESTE 4 - LATENCIA DA INTERNET" -ForegroundColor Cyan

$latencia = Test-Connection 1.1.1.1 -Count 4 |
Select-Object -ExpandProperty ResponseTime

$analise = $latencia | Measure-Object -Average -Minimum -Maximum

Write-Host ""
Write-Host "RESULTADO DA ANALISE" -ForegroundColor Yellow
Write-Host "Menor latencia: $($analise.Minimum) ms" -ForegroundColor Green
Write-Host "Maior latencia: $($analise.Maximum) ms" -ForegroundColor Yellow
Write-Host "Media de latencia: $([math]::Round($analise.Average, 2)) ms" -ForegroundColor Cyan

Write-Host ""
Write-Host "TESTE 5 - PERDA DE PACOTES" -ForegroundColor Cyan

$pacotes = Test-Connection 1.1.1.1 -Count 10

$enviados = 10
$recebidos = @($pacotes).Count
$perdidos = $enviados - $recebidos
$perda = (($perdidos / $enviados) * 100)

Write-Host "Pacotes enviados: $enviados"
Write-Host "Pacotes recebidos: $recebidos"
Write-Host "Pacotes perdidos: $perdidos"
Write-Host "Perda: $perda%" -ForegroundColor Yellow


Write-Host ""
Write-Host "TESTE 6 - RESOLUCAO DNS" -ForegroundColor Cyan

try {
    $dns = Resolve-DnsName google.com -ErrorAction Stop |
    Select-Object -First 1

    Write-Host "DNS funcionando!" -ForegroundColor Green
    Write-Host "Dominio: google.com"
    Write-Host "Endereco IP: $($dns.IPAddress)"
}
catch {
    Write-Host "Falha na resolucao DNS." -ForegroundColor Red
}

Write-Host ""
Write-Host "TESTE 7 - VELOCIDADE DE DOWNLOAD" -ForegroundColor Cyan

$url = "https://speed.cloudflare.com/__down?bytes=10000000"
$arquivoTeste = "$env:TEMP\teste-internet.tmp"

try {
    $cronometro = [System.Diagnostics.Stopwatch]::StartNew()

    Invoke-WebRequest -Uri $url -OutFile $arquivoTeste -ErrorAction Stop

    $cronometro.Stop()

    $tamanhoMB = (Get-Item $arquivoTeste).Length / 1MB
    $segundos = $cronometro.Elapsed.TotalSeconds
    $velocidade = ($tamanhoMB * 8) / $segundos

    Write-Host "Arquivo baixado: $([math]::Round($tamanhoMB, 2)) MB"
    Write-Host "Tempo: $([math]::Round($segundos, 2)) segundos"
    Write-Host "Velocidade aproximada: $([math]::Round($velocidade, 2)) Mbps" -ForegroundColor Green
}
catch {
    Write-Host "Nao foi possivel realizar o download de teste." -ForegroundColor Red
}
finally {
    Remove-Item $arquivoTeste -ErrorAction SilentlyContinue
}


Write-Host ""
Write-Host "TESTE 8 - ROTA ATE A INTERNET" -ForegroundColor Cyan

tracert -d -h 12 -w 1000 1.1.1.1

Write-Host ""
Write-Host "TESTE 9 - ESTABILIDADE DA CONEXAO" -ForegroundColor Cyan

$respostas = @(Test-Connection 1.1.1.1 -Count 20 -ErrorAction SilentlyContinue)

$tempos = @(
    $respostas |
    Where-Object { $_.ResponseTime -gt 0 } |
    Select-Object -ExpandProperty ResponseTime
)

if ($tempos.Count -gt 0) {

    $analiseEstabilidade = $tempos | Measure-Object -Average -Minimum -Maximum

    $variacoes = @()

    for ($i = 1; $i -lt $tempos.Count; $i++) {
        $variacoes += [math]::Abs($tempos[$i] - $tempos[$i - 1])
    }

    if ($variacoes.Count -gt 0) {
        $variacaoMedia = ($variacoes | Measure-Object -Average).Average
    } else {
        $variacaoMedia = 0
    }

    Write-Host "Respostas recebidas: $($tempos.Count) de 20"
    Write-Host "Menor latencia: $($analiseEstabilidade.Minimum) ms"
    Write-Host "Maior latencia: $($analiseEstabilidade.Maximum) ms"
    Write-Host "Media: $([math]::Round($analiseEstabilidade.Average, 2)) ms"
    Write-Host "Variacao media: $([math]::Round($variacaoMedia, 2)) ms" -ForegroundColor Yellow

} else {
    Write-Host "Nenhuma resposta recebida." -ForegroundColor Red
}


Write-Host ""
Write-Host "TESTE 10 - CONEXAO HTTPS" -ForegroundColor Cyan

try {
    $respostaHTTPS = Invoke-WebRequest `
        -Uri "https://www.cloudflare.com/cdn-cgi/trace" `
        -UseBasicParsing `
        -TimeoutSec 10 `
        -ErrorAction Stop

    Write-Host "Conexao HTTPS estabelecida!" -ForegroundColor Green
    Write-Host "Codigo HTTP: $($respostaHTTPS.StatusCode)"
}
catch {
    Write-Host "Falha ao acessar o servico HTTPS." -ForegroundColor Red
    Write-Host "Detalhe: $($_.Exception.Message)" -ForegroundColor Yellow
}


Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "       DIAGNOSTICO TECNICO"
Write-Host "====================================" -ForegroundColor Cyan

$problemas = 0

# ==================================
# ANALISE DE LATENCIA
# ==================================

Write-Host ""
Write-Host "1 - LATENCIA" -ForegroundColor Cyan

if ($analiseEstabilidade.Average -le 50) {
    Write-Host "Situacao: BOA" -ForegroundColor Green
}
elseif ($analiseEstabilidade.Average -le 100) {
    Write-Host "Situacao: REGULAR" -ForegroundColor Yellow
    $problemas++

    Write-Host "POSSIVEIS CAUSAS:"
    Write-Host "- Distancia elevada ate o servidor."
    Write-Host "- Rede da operadora sobrecarregada."
    Write-Host "- Problemas no caminho da conexao."

    Write-Host ""
    Write-Host "O QUE O TECNICO DEVE FAZER:"
    Write-Host "- Testar a latencia diretamente no roteador."
    Write-Host "- Comparar o resultado com um teste externo."
    Write-Host "- Verificar se outros clientes da mesma regiao apresentam o problema."
    Write-Host "- Conferir o caminho da conexao com o tracert."
}
else {
    Write-Host "Situacao: RUIM" -ForegroundColor Red
    $problemas++

    Write-Host "POSSIVEIS CAUSAS:"
    Write-Host "- Rede da operadora sobrecarregada."
    Write-Host "- Problemas na fibra ou nos equipamentos."
    Write-Host "- Caminho da conexao com falhas."

    Write-Host ""
    Write-Host "O QUE O TECNICO DEVE FAZER:"
    Write-Host "- Testar a latencia entre computador e roteador."
    Write-Host "- Conferir os niveis de sinal da ONU."
    Write-Host "- Verificar conectores e cabos de fibra."
    Write-Host "- Conferir a utilizacao da rede na OLT."
    Write-Host "- Comparar a latencia com outros clientes da mesma regiao."
}

# ==================================
# ANALISE DE PERDA DE PACOTES
# ==================================

Write-Host ""
Write-Host "2 - PERDA DE PACOTES" -ForegroundColor Cyan

if ($perda -eq 0) {
    Write-Host "Situacao: BOA" -ForegroundColor Green
}
elseif ($perda -le 2) {
    Write-Host "Situacao: REGULAR" -ForegroundColor Yellow
    $problemas++

    Write-Host "POSSIVEIS CAUSAS:"
    Write-Host "- Mau contato em cabos ou conectores."
    Write-Host "- Instabilidade na rede."
    Write-Host "- Sobrecarga em algum equipamento."

    Write-Host ""
    Write-Host "O QUE O TECNICO DEVE FAZER:"
    Write-Host "- Testar a comunicacao com o roteador."
    Write-Host "- Conferir os conectores de rede."
    Write-Host "- Verificar os niveis de sinal da ONU."
    Write-Host "- Repetir o teste com mais pacotes."
}
else {
    Write-Host "Situacao: RUIM" -ForegroundColor Red
    $problemas++

    Write-Host "POSSIVEIS CAUSAS:"
    Write-Host "- Falha na fibra optica."
    Write-Host "- Conector com sujeira ou mau contato."
    Write-Host "- Problema na ONU ou no roteador."
    Write-Host "- Rede da operadora sobrecarregada."

    Write-Host ""
    Write-Host "O QUE O TECNICO DEVE FAZER:"
    Write-Host "- Testar a perda de pacotes ate o roteador."
    Write-Host "- Se houver perda, verificar Wi-Fi, cabos e roteador."
    Write-Host "- Se nao houver perda ate o roteador, testar um destino externo."
    Write-Host "- Conferir os niveis de sinal da fibra."
    Write-Host "- Inspecionar conectores e cabos opticos."
    Write-Host "- Verificar a ONU, a porta PON e a rede da operadora."
}

# ==================================
# ANALISE DE ESTABILIDADE
# ==================================

Write-Host ""
Write-Host "3 - ESTABILIDADE" -ForegroundColor Cyan

if ($variacaoMedia -le 5) {
    Write-Host "Situacao: BOA" -ForegroundColor Green
}
elseif ($variacaoMedia -le 15) {
    Write-Host "Situacao: REGULAR" -ForegroundColor Yellow
    $problemas++

    Write-Host "POSSIVEIS CAUSAS:"
    Write-Host "- Oscilacao na rede."
    Write-Host "- Interferencia no Wi-Fi."
    Write-Host "- Variacao no tempo de resposta."

    Write-Host ""
    Write-Host "O QUE O TECNICO DEVE FAZER:"
    Write-Host "- Repetir o teste usando cabo de rede."
    Write-Host "- Verificar a qualidade do sinal Wi-Fi."
    Write-Host "- Comparar os resultados em diferentes horarios."
    Write-Host "- Conferir os niveis de sinal da ONU."
}
else {
    Write-Host "Situacao: RUIM" -ForegroundColor Red
    $problemas++

    Write-Host "POSSIVEIS CAUSAS:"
    Write-Host "- Instabilidade na fibra optica."
    Write-Host "- Interferencia ou falha no Wi-Fi."
    Write-Host "- Sobrecarga na rede da operadora."

    Write-Host ""
    Write-Host "O QUE O TECNICO DEVE FAZER:"
    Write-Host "- Repetir o teste por cabo."
    Write-Host "- Conferir conectores e cabos de fibra."
    Write-Host "- Medir o sinal optico recebido pela ONU."
    Write-Host "- Verificar a utilizacao da porta PON."
    Write-Host "- Comparar com outros clientes da mesma regiao."
}

# ==================================
# ANALISE DE DOWNLOAD
# ==================================

Write-Host ""
Write-Host "4 - VELOCIDADE DE DOWNLOAD" -ForegroundColor Cyan

if ($null -eq $velocidade) {
    Write-Host "Situacao: TESTE NAO CONCLUIDO" -ForegroundColor Yellow
    Write-Host "O QUE O TECNICO DEVE FAZER:"
    Write-Host "- Verificar se existe acesso ao servidor de teste."
    Write-Host "- Repetir o teste em outro servidor."
    $problemas++
}
elseif ($velocidade -ge 25) {
    Write-Host "Situacao: BOA" -ForegroundColor Green
}
elseif ($velocidade -ge 5) {
    Write-Host "Situacao: REGULAR" -ForegroundColor Yellow
    $problemas++

    Write-Host "POSSIVEIS CAUSAS:"
    Write-Host "- Velocidade configurada abaixo do contratado."
    Write-Host "- Wi-Fi com sinal fraco."
    Write-Host "- Rede da operadora sobrecarregada."

    Write-Host ""
    Write-Host "O QUE O TECNICO DEVE FAZER:"
    Write-Host "- Comparar a velocidade com o plano contratado."
    Write-Host "- Realizar teste diretamente por cabo."
    Write-Host "- Conferir a velocidade configurada para o cliente."
    Write-Host "- Verificar os niveis de sinal da ONU."
    Write-Host "- Conferir a utilizacao da porta PON."
}
else {
    Write-Host "Situacao: RUIM" -ForegroundColor Red
    $problemas++

    Write-Host "POSSIVEIS CAUSAS:"
    Write-Host "- Perfil de velocidade configurado incorretamente."
    Write-Host "- Perda de sinal na fibra."
    Write-Host "- Rede da operadora sobrecarregada."
    Write-Host "- Problema no roteador ou na ONU."

    Write-Host ""
    Write-Host "O QUE O TECNICO DEVE FAZER:"
    Write-Host "- Repetir o teste diretamente por cabo."
    Write-Host "- Conferir o plano e a velocidade configurada."
    Write-Host "- Medir o sinal optico recebido pela ONU."
    Write-Host "- Inspecionar conectores e cabos de fibra."
    Write-Host "- Verificar a porta PON e sua utilizacao."
    Write-Host "- Testar com outro equipamento, se necessario."
}

# ==================================
# ANALISE HTTPS
# ==================================

Write-Host ""
Write-Host "5 - CONEXAO HTTPS" -ForegroundColor Cyan

if ($null -ne $respostaHTTPS -and $respostaHTTPS.StatusCode -eq 200) {
    Write-Host "Situacao: BOA" -ForegroundColor Green
}
else {
    Write-Host "Situacao: FALHA" -ForegroundColor Red
    $problemas++

    Write-Host "POSSIVEIS CAUSAS:"
    Write-Host "- Falha na resolucao DNS."
    Write-Host "- Bloqueio da porta 443."
    Write-Host "- Problema de certificado ou horario do computador."
    Write-Host "- Restricao de acesso na rede."

    Write-Host ""
    Write-Host "O QUE O TECNICO DEVE FAZER:"
    Write-Host "- Testar a resolucao DNS."
    Write-Host "- Verificar o acesso a outros sites HTTPS."
    Write-Host "- Testar a porta 443."
    Write-Host "- Conferir data e horario do computador."
    Write-Host "- Verificar firewall e bloqueios na rede."
}

# ==================================
# RESULTADO FINAL
# ==================================

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "         RESULTADO FINAL"
Write-Host "====================================" -ForegroundColor Cyan

if ($problemas -eq 0) {
    Write-Host "Diagnostico: REDE SEM ALERTAS" -ForegroundColor Green
    Write-Host "Nenhum dos indicadores analisados apresentou problema."
}
elseif ($problemas -le 2) {
    Write-Host "Diagnostico: REDE COM PONTOS DE ATENCAO" -ForegroundColor Yellow
    Write-Host "Verifique os procedimentos recomendados acima."
}
else {
    Write-Host "Diagnostico: REDE COM VARIOS PROBLEMAS" -ForegroundColor Red
    Write-Host "Recomendada uma verificacao tecnica completa."
}

Write-Host ""
Write-Host "Indicadores com problemas: $problemas"
Write-Host "Diagnostico tecnico concluido!"

