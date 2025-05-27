package project;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/deleteRestaurant")
public class RestaurantDeleteServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int rst_id = Integer.parseInt(request.getParameter("rst_id"));
        String pageNum = request.getParameter("pageNum");
        String searchType = request.getParameter("searchType");
        String searchKeyword = request.getParameter("searchKeyword");

        RestaurantMgr mgr = new RestaurantMgr();

        // ✅ member_role 복구도 포함한 삭제 로직 사용
        boolean result = mgr.deleteRestaurantAndMaybeUpdateRole(rst_id);

        // 리디렉션 URL 구성
        String redirectURL = request.getContextPath() + "/project/admin/admin_Rst_List.jsp?deleteSuccess=" + result + "&pageNum=" + pageNum;

        if (searchType != null && !searchType.isEmpty()) {
            redirectURL += "&searchType=" + searchType;
        }
        if (searchKeyword != null && !searchKeyword.isEmpty()) {
            redirectURL += "&searchKeyword=" + searchKeyword;
        }

        response.sendRedirect(redirectURL);
    }
}
