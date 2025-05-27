<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="project.InquiryBean"%>
<%
    InquiryBean inquiry = (InquiryBean) request.getAttribute("inquiry");

    String status = inquiry.getInq_status();
    String statusClass = "";
    if ("대기중".equals(status)) {
        statusClass = "status-pending";
    } else if ("완료".equals(status)) {
        statusClass = "status-completed";
    }
%> 
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>문의 상세 정보</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/project/css/admin_Inquiry_Detail.css">
<script>
    function closeModal() {
        window.close(); // 팝업 창 닫기
    }
</script>
</head>
<body>
    <div class="modal-overlay" id="inquiryModal">
        <div class="modal-content">
            <div class="modal-close" onclick="closeModal()">✕</div>
            <h2>문의 상세 정보</h2>

            <div class="info-box">
                <span class="label">문의 번호:</span>
                <%=inquiry.getInq_id()%>
            </div>
            <div class="info-box">
                <span class="label">문의 유형:</span>
                <%=inquiry.getInq_type()%>
            </div>
            <div class="info-box">
                <span class="label">작성자:</span>
                <%=inquiry.getMember_name()%>
                (<%=inquiry.getMember_email()%>)
            </div>
            <div class="info-box">
                <span class="label">연락처:</span>
                <%=inquiry.getMember_phone()%>
            </div>
            <div class="info-box">
                <span class="label">작성일:</span>
                <%=inquiry.getInq_create_at()%>
            </div>
            <div class="info-box">
                <span class="label">상태:</span> 
                <span class="status-label <%=statusClass%>"><%=status%></span>
            </div>

            <h4>문의 내용</h4>
            <div class="info-box">
                <span class="label">제목:</span>
                <%=inquiry.getInq_title()%>
            </div>
            <textarea readonly><%=inquiry.getInq_content()%></textarea>

            <h4>답변</h4>
            <% if ("완료".equals(status)) { %>
                <!-- 완료된 문의에 대해서는 "답변 완료" 버튼을 숨기고 처리 완료 문구를 표시합니다. -->
                <p>이미 처리가 된 문의입니다.</p>
            <% } else { %>
                <form action="/myapp/admin/inquiryReply.do" method="post">
                    <input type="hidden" name="inq_id" value="<%=inquiry.getInq_id()%>" />
                    <textarea name="reply" placeholder="답변을 작성하세요......"></textarea>
                    <div class="btn-group">
                        <button type="submit" name="action" value="register">답변 등록</button>
                    </div>
                </form>
            <% } %>

        </div>
    </div>
</body>
</html>
