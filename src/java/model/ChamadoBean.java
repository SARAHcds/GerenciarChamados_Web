package model;

import java.util.Date;

/*
Armazena os dados do chamado.
As regras de prioridade, SLA e transição de status (ITIL 4) ficam aqui como métodos estáticos.
*/
public class ChamadoBean {

    // Valores permitidos (iguais aos CHECK do banco)
    public static final String[] TIPOS = {"Incidente", "Requisição de serviço"};
    public static final String[] CATEGORIAS = {"Hardware", "Software / Sistema", "Rede / Acesso",
        "Impressora / Periféricos", "Solicitação / Dúvida"};
    public static final String[] NIVEIS_IMPACTO = {"Alto", "Médio", "Baixo"};
    public static final String[] NIVEIS_URGENCIA = {"Alta", "Média", "Baixa"};

    public static final String STATUS_ABERTO = "Aberto";
    public static final String STATUS_EM_ANALISE = "Em análise";
    public static final String STATUS_EM_ANDAMENTO = "Em andamento";
    public static final String STATUS_AGUARDANDO = "Aguardando usuário";
    public static final String STATUS_CONCLUIDO = "Concluído";

    private int idChamado;
    private String titulo;
    private String descricao;
    private String tipo;
    private String categoria;
    private String impacto;
    private String urgencia;
    private String prioridade;
    private String status;
    private int slaHoras;
    private Date dataAbertura;
    private Date dataAtualizacao;
    private Date dataConclusao;
    private String solucaoResumo;
    private String observacao;
    private int idUsuario;   // solicitante
    private int idTecnico;   // 0 = sem responsável (NULL no banco)
    private String nomeSolicitante;
    private String nomeTecnico;

    // ---------- Regras de negócio (ITIL 4) ----------

    // Pontuação de cada nível: Alto/Alta = 3, Médio/Média = 2, Baixo/Baixa = 1
    private static int pontos(String nivel) {
        switch (nivel) {
            case "Alto":
            case "Alta":
                return 3;
            case "Médio":
            case "Média":
                return 2;
            default:
                return 1;
        }
    }

    // Prioridade = impacto + urgência. Soma 6 = P1; 5 = P2; 4 = P3; 3 ou 2 = P4.
    public static String calcularPrioridade(String impacto, String urgencia) {
        int soma = pontos(impacto) + pontos(urgencia);
        if (soma >= 6) return "P1";
        if (soma == 5) return "P2";
        if (soma == 4) return "P3";
        return "P4";
    }

    // SLA em horas, definido pela prioridade
    public static int slaPorPrioridade(String prioridade) {
        switch (prioridade) {
            case "P1": return 4;
            case "P2": return 8;
            case "P3": return 24;
            default:   return 72;
        }
    }

    // Fluxo de status. "Aberto -> Em análise" só acontece ao assumir o chamado.
    // "Concluído" é final.
    public static boolean transicaoPermitida(String de, String para) {
        switch (de) {
            case STATUS_EM_ANALISE:
                return STATUS_EM_ANDAMENTO.equals(para) || STATUS_AGUARDANDO.equals(para);
            case STATUS_EM_ANDAMENTO:
                return STATUS_AGUARDANDO.equals(para) || STATUS_CONCLUIDO.equals(para);
            case STATUS_AGUARDANDO:
                return STATUS_EM_ANDAMENTO.equals(para);
            default:
                return false;
        }
    }

    // ---------- Getters e setters ----------

    public int getIdChamado() { return idChamado; }
    public void setIdChamado(int idChamado) { this.idChamado = idChamado; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }

    public String getImpacto() { return impacto; }
    public void setImpacto(String impacto) { this.impacto = impacto; }

    public String getUrgencia() { return urgencia; }
    public void setUrgencia(String urgencia) { this.urgencia = urgencia; }

    public String getPrioridade() { return prioridade; }
    public void setPrioridade(String prioridade) { this.prioridade = prioridade; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getSlaHoras() { return slaHoras; }
    public void setSlaHoras(int slaHoras) { this.slaHoras = slaHoras; }

    public Date getDataAbertura() { return dataAbertura; }
    public void setDataAbertura(Date dataAbertura) { this.dataAbertura = dataAbertura; }

    public Date getDataAtualizacao() { return dataAtualizacao; }
    public void setDataAtualizacao(Date dataAtualizacao) { this.dataAtualizacao = dataAtualizacao; }

    public Date getDataConclusao() { return dataConclusao; }
    public void setDataConclusao(Date dataConclusao) { this.dataConclusao = dataConclusao; }

    public String getSolucaoResumo() { return solucaoResumo; }
    public void setSolucaoResumo(String solucaoResumo) { this.solucaoResumo = solucaoResumo; }

    public String getObservacao() { return observacao; }
    public void setObservacao(String observacao) { this.observacao = observacao; }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public int getIdTecnico() { return idTecnico; }
    public void setIdTecnico(int idTecnico) { this.idTecnico = idTecnico; }

    public String getNomeSolicitante() { return nomeSolicitante; }
    public void setNomeSolicitante(String nomeSolicitante) { this.nomeSolicitante = nomeSolicitante; }

    public String getNomeTecnico() { return nomeTecnico; }
    public void setNomeTecnico(String nomeTecnico) { this.nomeTecnico = nomeTecnico; }
}
