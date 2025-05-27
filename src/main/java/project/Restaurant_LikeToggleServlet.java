package project;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/project/rst/Restaurant_LikeToggleServlet")
public class Restaurant_LikeToggleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession();
        String memberId = (String) session.getAttribute("idKey");
        String reviewIdStr = request.getParameter("rst_id");

        int rst_id = 0;
        try {
        	rst_id = Integer.parseInt(reviewIdStr);
        } catch (NumberFormatException e) {
        	rst_id = -1;
        }

        RestaurantLikeMgr likeMgr = new RestaurantLikeMgr();
        RestaurantLikeBean bean = new RestaurantLikeBean();
        bean.setMember_id(memberId);
        bean.setRst_id(rst_id);

        boolean liked = false;
        int likeCount = 0;

        if (memberId != null && rst_id > 0) {
            liked = likeMgr.toggleLike(bean);
            likeCount = likeMgr.likeCount(rst_id);
        }

        // JSON 문자열 직접 만들기
        String json = "{"
                    + "\"success\": " + (memberId != null) + ","
                    + "\"liked\": " + liked + ","
                    + "\"newLikeCount\": " + likeCount
                    + "}";
        PrintWriter out = response.getWriter();
        out.print(json);
        out.close();
    }
}
