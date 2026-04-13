# 🛡️ Segurança e Auditoria — BOOST FPS

O **BOOST FPS** foi projetado sob o princípio da **transparência**. Como um software que realiza modificações profundas no sistema operacional, é vital que o usuário saiba exatamente o que está acontecendo e como reverter o processo.

---

## 1. Sistema de Ponto de Restauração (Shadow Copies)

O software implementa uma trava de segurança baseada no **Windows Volume Shadow Copy Service (VSS)**:

- **Verificação Inicial**: Ao iniciar, o app consulta o sistema por pontos de restauração criados nas últimas 24 horas.
- **Criação Obrigatória**: Se nenhum ponto for encontrado, o app solicita a criação imediata.
- **Script Técnico**: O script `backup/create-restore-point.ps1` utiliza o comando `Checkpoint-Computer` do PowerShell com a descrição `"Azucrinaldo_Boost_Original_State"`.

## 2. Log de Auditoria em Tempo Real

Cada ação tomada pelos scripts PowerShell é reportada de volta para a interface do Electron:

- **Rastreabilidade**: O log exibe exatamente qual chave de registro foi criada, modificada ou qual serviço foi interrompido.
- **Salvamento de Log**: O usuário pode exportar o log completo da sessão atual para um arquivo `.txt` clicando em **"SALVAR ARQUIVO DE AUDITORIA"**. Isso serve como prova técnica do que foi alterado.

## 3. Filosofia de "Código Aberto Local"

Diferente de ferramentas `.exe` fechadas que escondem suas operações, o BOOST FPS:
- Mantém todos os arquivos `.ps1` (scripts) legíveis e editáveis na pasta `/scripts`.
- Permite que qualquer usuário avançado inspecione as linhas de código antes de clicar em "Executar".

## 4. O Sistema de Rollback

O botão **Azucri-RollBack** é a "chave de emergência" do app:
1. Ele invoca o processo de restauração do Windows para o ponto criado antes das otimizações.
2. O sistema é reiniciado automaticamente para restaurar o `Registry`, `Drivers` e `Services` ao estado virgem.

## 5. Riscos do Módulo BIOHAZARD (Importante)

O módulo de otimização extrema desativa proteções de hardware e Kernel:
- **Spectre/Meltdown**: Desativar essas mitigações melhora a performance de IPC (Instruções por Ciclo), mas torna o navegador vulnerável a ataques de roubo de dados via JavaScript em sites maliciosos.
- **DMA Protection**: Desativar a proteção de acesso direto à memória acelera periféricos mas remove uma camada de proteção física.

**RECOMENDAÇÃO**: Utilize esses módulos apenas em computadores dedicados a jogos e evite realizar transações bancárias ou acessar dados sensíveis enquanto essas otimizações extremas estiverem ativas.

---
*Segurança é um trabalho em equipe entre o software e o usuário.*
