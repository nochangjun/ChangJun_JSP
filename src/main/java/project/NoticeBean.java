package project;

public class NoticeBean {
	private int notice_id;
	private int is_read;  
	private int comment_id;  
	private int rst_id;  
	private int inq_id;  
	private int report_id;
	private String status_info;
	private String member_id;
	
	private String inq_title;
	private String board_writer_id;
	private boolean isReply;         // 대댓글 여부
	private int board_id;            // 게시글 번호
	private String board_title;      // 게시글 제목
	
	private String report_type;	// join을 통해 조회
	private String report_status;
	private String reporter_id;
	private String reported_member_id;
	
	public NoticeBean() {}

	public int getNotice_id() {
		return notice_id;
	}

	public void setNotice_id(int notice_id) {
		this.notice_id = notice_id;
	}

	public int getIs_read() {
		return is_read;
	}

	public void setIs_read(int is_read) {
		this.is_read = is_read;
	}

	public int getComment_id() {
		return comment_id;
	}

	public void setComment_id(int comment_id) {
		this.comment_id = comment_id;
	}

	public int getRst_id() {
		return rst_id;
	}

	public void setRst_id(int rst_id) {
		this.rst_id = rst_id;
	}

	public int getInq_id() {
		return inq_id;
	}

	public void setInq_id(int inq_id) {
		this.inq_id = inq_id;
	}

	public int getReport_id() {
		return report_id;
	}

	public void setReport_id(int report_id) {
		this.report_id = report_id;
	}
	
	public String getStatus_info() {
	    return status_info;
	}

	public void setStatus_info(String status_info) {
	    this.status_info = status_info;
	}
	
	public String getMember_id() {
		return member_id;
	}

	public void setMember_id(String member_id) {
		this.member_id = member_id;
	}

	public String getInq_title() {
	    return inq_title;
	}

	public void setInq_title(String inq_title) {
	    this.inq_title = inq_title;
	}
	
	public String getBoard_writer_id() {
	    return board_writer_id;
	}

	public void setBoard_writer_id(String board_writer_id) {
	    this.board_writer_id = board_writer_id;
	}
	
	public boolean isReply() {
	    return isReply;
	}
	public void setIsReply(boolean isReply) {
	    this.isReply = isReply;
	}
	
	public int getBoard_id() {
	    return board_id;
	}
	
	public void setBoard_id(int board_id) {
	    this.board_id = board_id;
	}
	
	public String getBoard_title() {
	    return board_title;
	}
	
	public void setBoard_title(String board_title) {
	    this.board_title = board_title;
	}
	
	public String getReport_type() { 
		return report_type; 
	}
	
	public void setReport_type(String report_type) { 
		this.report_type = report_type; 
	}
	
	public String getReport_status() {
	    return report_status;
	}

	public void setReport_status(String report_status) {
	    this.report_status = report_status;
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
}
