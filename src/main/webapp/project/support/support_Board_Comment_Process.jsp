<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.*" %>
<jsp:useBean id="cMgr" class="project.CommentMgr"/>
<jsp:useBean id="bean" class="project.CommentBean"/>
<%
    request.setCharacterEncoding("UTF-8");
    
    // 세션에서 로그인한 사용자 ID 가져오기
    String memberId = (String)session.getAttribute("idKey");
    if(memberId == null || memberId.trim().equals("")) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login/login.jsp';</script>");
        return;
    }
    
    String action = request.getParameter("action");
    int boardId = Integer.parseInt(request.getParameter("boardId"));
    
    boolean result = false;
    String msg = "";
    
    if(action.equals("insert")) {
        // 댓글 등록
        String content = request.getParameter("content");
        
        // 서버측 내용 검증 추가
        if(content == null || content.trim().equals("")) {
            out.println("<script>alert('댓글 내용을 입력해주세요.'); history.back();</script>");
            return;
        }
        
        // 대댓글인 경우
        String parentIdParam = request.getParameter("parentId");
        
        if(parentIdParam != null && !parentIdParam.equals("")) {
            int parentId = Integer.parseInt(parentIdParam);
            // 디버깅용 로그
            System.out.println("대댓글 등록: boardId=" + boardId + ", memberId=" + memberId + ", content=" + content + ", parentId=" + parentId);
            bean = new CommentBean(boardId, memberId, content, parentId);
        } else {
            // 디버깅용 로그
            System.out.println("일반 댓글 등록: boardId=" + boardId + ", memberId=" + memberId + ", content=" + content);
            bean = new CommentBean(boardId, memberId, content);
        }
        
        result = cMgr.insertComment(bean);
        msg = result ? "댓글이 등록되었습니다." : "신고 제한 상태입니다. 댓글을 작성할 수 없습니다.";
    } 
    else if(action.equals("update")) {
        // 댓글 수정
        int commentId = Integer.parseInt(request.getParameter("commentId"));
        String content = request.getParameter("content");
        
        // 서버측 내용 검증 추가
        if(content == null || content.trim().equals("")) {
            out.println("<script>alert('댓글 내용을 입력해주세요.'); history.back();</script>");
            return;
        }
        
        bean.setComment_id(commentId);
        bean.setMember_id(memberId);
        bean.setComment_content(content);
        
        result = cMgr.updateComment(bean);
        msg = result ? "댓글이 수정되었습니다." : "댓글 수정에 실패했습니다.";
    } 
    else if(action.equals("delete")) {
        // 댓글 삭제
        int commentId = Integer.parseInt(request.getParameter("commentId"));
        result = cMgr.deleteComment(commentId, memberId);
        msg = result ? "댓글이 삭제되었습니다." : "댓글 삭제에 실패했습니다.";
    }
    
    // 알림 후 상세 페이지로 리다이렉트
    out.println("<script>");
    out.println("alert('" + msg + "');");
    out.println("location.href='support_Board_Detail.jsp?id=" + boardId + "';");
    out.println("</script>");
%>