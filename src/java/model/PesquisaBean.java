package model;

import java.util.Date;

/*
Armazena as respostas da pesquisa de satisfação de um chamado concluído.
q1 a q8 aceitam somente 1, 2, 3 ou 4.
nomeUsuario e tituloChamado vêm de JOIN e servem só para os relatórios.
*/
public class PesquisaBean {

    private int idPesquisa;
    private int idChamado;
    private int idUsuario;
    private int idTecnico;
    private Date dataResposta;
    private int q1, q2, q3, q4, q5, q6, q7, q8;
    private String observacao;
    private String nomeUsuario;
    private String tituloChamado;

    public int getIdPesquisa() { return idPesquisa; }
    public void setIdPesquisa(int idPesquisa) { this.idPesquisa = idPesquisa; }

    public int getIdChamado() { return idChamado; }
    public void setIdChamado(int idChamado) { this.idChamado = idChamado; }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public int getIdTecnico() { return idTecnico; }
    public void setIdTecnico(int idTecnico) { this.idTecnico = idTecnico; }

    public Date getDataResposta() { return dataResposta; }
    public void setDataResposta(Date dataResposta) { this.dataResposta = dataResposta; }

    public int getQ1() { return q1; }
    public void setQ1(int q1) { this.q1 = q1; }

    public int getQ2() { return q2; }
    public void setQ2(int q2) { this.q2 = q2; }

    public int getQ3() { return q3; }
    public void setQ3(int q3) { this.q3 = q3; }

    public int getQ4() { return q4; }
    public void setQ4(int q4) { this.q4 = q4; }

    public int getQ5() { return q5; }
    public void setQ5(int q5) { this.q5 = q5; }

    public int getQ6() { return q6; }
    public void setQ6(int q6) { this.q6 = q6; }

    public int getQ7() { return q7; }
    public void setQ7(int q7) { this.q7 = q7; }

    public int getQ8() { return q8; }
    public void setQ8(int q8) { this.q8 = q8; }

    public String getObservacao() { return observacao; }
    public void setObservacao(String observacao) { this.observacao = observacao; }

    public String getNomeUsuario() { return nomeUsuario; }
    public void setNomeUsuario(String nomeUsuario) { this.nomeUsuario = nomeUsuario; }

    public String getTituloChamado() { return tituloChamado; }
    public void setTituloChamado(String tituloChamado) { this.tituloChamado = tituloChamado; }
}
