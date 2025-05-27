package project;

import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import project.RestaurantMgr;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/project/updateRestaurant")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 1024 * 1024 * 10,  // 10MB
    maxRequestSize = 1024 * 1024 * 20
)
public class RestaurantUpdateServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String memberId = (String) session.getAttribute("idKey");

        if (memberId == null) {
            response.sendRedirect("../login/login.jsp");
            return;
        }

    	int rst_id = Integer.parseInt(request.getParameter("rst_id"));
        String rst_name = request.getParameter("rst_name");
        String rst_phonenumber = request.getParameter("rst_phonenumber");
        String rst_address = request.getParameter("rst_address");
        String rst_introduction = request.getParameter("rst_introduction");
        String rst_tag = request.getParameter("rst_tag");
        String rst_status = request.getParameter("rst_status");

        double rst_lat = Double.parseDouble(request.getParameter("rst_lat"));
        double rst_long = Double.parseDouble(request.getParameter("rst_long"));
        String regionLabel = request.getParameter("regionLabel");
        String region2Label = request.getParameter("region2Label");

        // 이미지 처리
        String imgpath = null;
        Part filePart = request.getPart("imageFile");
        if (filePart != null && filePart.getSize() > 0) {
            String uploadPath = request.getServletContext().getRealPath("/upload/restaurant");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String fileName = UUID.randomUUID().toString() + "_" + filePart.getSubmittedFileName();
            filePart.write(uploadPath + File.separator + fileName);
            imgpath = "/upload/restaurant/" + fileName;
        } else {
            // 기존 이미지 유지
            RestaurantMgr mgr = new RestaurantMgr();
            RestaurantBean oldData = mgr.getRestaurantByMemberId(memberId);
            imgpath = oldData.getImgpath();  // 기존 이미지 경로 복사
        }

        RestaurantBean bean = new RestaurantBean();
        bean.setRst_id(rst_id);
        bean.setRst_name(rst_name);
        bean.setRst_phonenumber(rst_phonenumber);
        bean.setRst_address(rst_address);
        bean.setRst_introduction(rst_introduction);
        bean.setRst_tag(rst_tag);
        bean.setRst_status(rst_status);
        bean.setRst_lat(rst_lat);
        bean.setRst_long(rst_long);
        bean.setRegionLabel(regionLabel);
        bean.setRegion2Label(region2Label);
        if (imgpath != null) bean.setImgpath(imgpath);
        bean.setMember_id(memberId);
        
        RestaurantMgr mgr = new RestaurantMgr();
        boolean result = mgr.updateRestaurantByMember(bean);
        
        if (result) {
			response.sendRedirect("my/my_Store_Update.jsp?updated=true");
		} else {
			response.sendRedirect("my/my_Store_Update.jsp?updated=false");
		}
    }
}
