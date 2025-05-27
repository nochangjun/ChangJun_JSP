package project;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RstApproveServlet")
public class RstApproveServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
	        throws ServletException, IOException {
	    
	    request.setCharacterEncoding("UTF-8");
	    
	    int rstId = Integer.parseInt(request.getParameter("rst_id"));
	    String pageNum = request.getParameter("pageNum");
	    String searchType = request.getParameter("searchType");
	    String searchKeyword = request.getParameter("searchKeyword");

	    RestaurantMgr mgr = new RestaurantMgr();
	    boolean result = mgr.approveRestaurantAndUpdateRole(rstId);

	    // 기본 URL 설정
	    String redirectURL = request.getContextPath() + "/project/admin/admin_Rst_List.jsp?msg=" + (result ? "approved" : "error");

	    // 검색/페이징 파라미터 유지
	    if (pageNum != null && !pageNum.isEmpty()) {
	        redirectURL += "&pageNum=" + pageNum;
	    }
	    if (searchType != null && !searchType.isEmpty()) {
	        redirectURL += "&searchType=" + searchType;
	    }
	    if (searchKeyword != null && !searchKeyword.isEmpty()) {
	        redirectURL += "&searchKeyword=" + searchKeyword;
	    }

	    response.sendRedirect(redirectURL);
	}
}
