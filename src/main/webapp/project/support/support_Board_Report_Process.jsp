<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.*" %>
<jsp:useBean id="reportMgr" class="project.ReportMgr"/>
<%
    request.setCharacterEncoding("UTF-8");
    
    // 세션에서 로그인한 사용자 ID 가져오기
    String memberId = (String)session.getAttribute("idKey");
    if(memberId == null || memberId.trim().equals("")) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login/login.jsp';</script>");
        return;
    }
    
    
    String action = request.getParameter("action");
    String reportType = request.getParameter("reportType");
    int targetId = Integer.parseInt(request.getParameter("targetId"));
    String boardIdParam = request.getParameter("boardId");
    int boardId = 0;
    if (boardIdParam != null && !boardIdParam.trim().isEmpty()) {
        boardId = Integer.parseInt(boardIdParam);
    }
    
    String returnUrl = request.getParameter("returnUrl");
    if (returnUrl == null || returnUrl.trim().equals("")) {
        // fallback 처리: 게시글이면 boardId로 이동
        returnUrl = "support_Board_Detail.jsp?id=" + boardId;
    } else {
        returnUrl = java.net.URLDecoder.decode(returnUrl, "UTF-8");
    }

    String reason = request.getParameter("reason");
    
    boolean result = false;
    String message = "";
    String redirectUrl = "support_Board_Detail.jsp?id=" + boardId; // 기본값

    if(action.equals("report")) {
        if(reportType.equals("comment")) {
            // 댓글 신고 처리
            result = reportMgr.reportComment(memberId, targetId, reason);
            message = result ? "댓글이 신고되었습니다." : "이미 신고한 댓글이거나 신고할 수 없는 댓글입니다.";
            redirectUrl = "support_Board_Detail.jsp?id=" + boardId;
        } else if(reportType.equals("board")) {
            // 게시글 신고 처리
            result = reportMgr.reportBoard(memberId, targetId, reason);
            message = result ? "게시글이 신고되었습니다." : "이미 신고한 게시글이거나 신고할 수 없는 게시글입니다.";
            redirectUrl = "support_Board_Detail.jsp?id=" + boardId;
        } else if(reportType.equals("review")) {
            // 리뷰 신고 처리
            reportMgr.reportReview(memberId, targetId, reason);
            int restaurantId = reportMgr.getRestaurantIdByReview(targetId); // 이 메서드가 필요함
            redirectUrl = "../rst/rst_Detail.jsp?rst_id=" + restaurantId;
        }
    }

    // 알림 후 리다이렉트
    out.println("<script>");
    out.println("location.href='" + returnUrl + "';");
    out.println("</script>");
%>
