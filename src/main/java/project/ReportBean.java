package project;

import java.sql.Timestamp;

public class ReportBean {
    private int report_id;               // 신고 고유 번호 (자동증가)
    private String report_type;          // 신고 유형: "board", "comment", "review"
    private int report_target_id;        // 신고 대상의 ID (게시판, 댓글, 리뷰 중 하나)
    private String report_reason;        // 신고 사유
    private String reporter_id;          // 신고자 ID
    private String reported_member_id;   // 신고당한 작성자 ID
    private Timestamp report_created_at; // 신고 접수 시간
    private String report_status;        // 신고 상태: "pending", "processed", "dismissed"
    private String member_name; // 신고당한 회원의 이름

    // Getter & Setter
    public int getReport_id() {
        return report_id;
    }
    public void setReport_id(int report_id) {
        this.report_id = report_id;
    }
    public String getReport_type() {
        return report_type;
    }
    public void setReport_type(String report_type) {
        this.report_type = report_type;
    }
    public int getReport_target_id() {
        return report_target_id;
    }
    public void setReport_target_id(int report_target_id) {
        this.report_target_id = report_target_id;
    }
    public String getReport_reason() {
        return report_reason;
    }
    public void setReport_reason(String report_reason) {
        this.report_reason = report_reason;
    }
    public String getReporter_id() {
        return reporter_id;
    }
    public void setReporter_id(String reporter_id) {
        this.reporter_id = reporter_id;
    }
    public String getReported_member_id() {
        return reported_member_id;
    }
    public void setReported_member_id(String reported_member_id) {
        this.reported_member_id = reported_member_id;
    }
    public Timestamp getReport_created_at() {
        return report_created_at;
    }
    public void setReport_created_at(Timestamp report_created_at) {
        this.report_created_at = report_created_at;
    }
    public String getReport_status() {
        return report_status;
    }
    public void setReport_status(String report_status) {
        this.report_status = report_status;
    }
    
    public String getMember_name() {
        return member_name;
    }

    public void setMember_name(String member_name) {
        this.member_name = member_name;
    }

}
