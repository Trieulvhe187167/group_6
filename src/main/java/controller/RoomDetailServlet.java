package controller;

import dal.RoomTypeDAO;
import dal.RoomDAO;
import jakarta.servlet.ServletContext;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import model.RoomType;
import model.Room;

/**
 * Servlet for handling user room detail view
 */
@WebServlet(name = "RoomDetailServlet", urlPatterns = {"/RoomDetailServlet"})
public class RoomDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("RoomListServlet");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);

            RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
            RoomDAO roomDAO = new RoomDAO();

            // Get room type details
            RoomType roomType = roomTypeDAO.getRoomTypesById(id);

            if (roomType == null) {
                request.setAttribute("error", "Room type not found");
                response.sendRedirect("RoomListServlet");
                return;
            }

            // Only show active room types to users
            if (!"active".equals(roomType.getStatus())) {
                request.setAttribute("error", "Room type is not available");
                response.sendRedirect("RoomListServlet");
                return;
            }

            // Get available rooms for this room type
            List<Room> allRooms = roomDAO.getRoomsByType(id);
            List<Room> availableRooms = roomDAO.getAvailableRoomsByType(id);

            // Calculate room statistics
            int totalRooms = allRooms.size();
            int availableCount = availableRooms.size();
            int occupiedCount = 0;
            int maintenanceCount = 0;

            for (Room room : allRooms) {
                switch (room.getStatus()) {
                    case "OCCUPIED":
                        occupiedCount++;
                        break;
                    case "MAINTENANCE":
                    case "DIRTY":
                        maintenanceCount++;
                        break;
                }
            }

            String folderName = roomTypeDAO.getRoomImageFolderUrl(id);
            List<String> imageUrls = new ArrayList<>();
            if (folderName != null && !folderName.isEmpty()) {
                String webBaseUrl = "/assets/images/room-type/";
                String folderWebUrl = webBaseUrl + folderName;
                ServletContext context = getServletContext();
                String realPath = context.getRealPath(folderWebUrl);
                
                File folder = new File(realPath);
                
                if (folder.exists() && folder.isDirectory()) {
                    File[] filesArray = folder.listFiles();
                    if (filesArray != null) {
                        // Bắt đầu thêm logic sắp xếp
                        List<File> fileList = new ArrayList<>(Arrays.asList(filesArray));

                        // Danh sách thứ tự ưu tiên theo từ khóa
                        List<String> priority = Arrays.asList("overview", "livingroom", "window", "bed", "bathroom", "table");

                        // Sắp xếp ảnh theo thứ tự ưu tiên
                        fileList.sort((f1, f2) -> {
                            String name1 = f1.getName().toLowerCase();
                            String name2 = f2.getName().toLowerCase();

                            int index1 = priority.size(); // mặc định là cuối
                            int index2 = priority.size();

                            for (int i = 0; i < priority.size(); i++) {
                                if (name1.contains(priority.get(i))) {
                                    index1 = i;
                                    break; // Thoát vòng lặp khi tìm thấy từ khóa
                                }
                            }
                            for (int i = 0; i < priority.size(); i++) {
                                if (name2.contains(priority.get(i))) {
                                    index2 = i;
                                    break; // Thoát vòng lặp khi tìm thấy từ khóa
                                }
                            }

                            // Nếu cả hai đều không nằm trong danh sách -> sắp xếp theo tên bình thường
                            if (index1 == index2) {
                                return name1.compareTo(name2);
                            }

                            return Integer.compare(index1, index2);
                        });

                        // Duyệt qua danh sách đã sắp xếp để tạo URL
                        for (File file : fileList) {
                            String fileName = file.getName();
                            if (fileName.toLowerCase().endsWith(".jpg") || 
                                    fileName.toLowerCase().endsWith(".jpeg") || 
                                    fileName.toLowerCase().endsWith(".png") || 
                                    fileName.toLowerCase().endsWith(".webp") ||
                                    fileName.toLowerCase().endsWith(".gif")) {
                                imageUrls.add(folderWebUrl + "/" + fileName);
                            }
                        }
                    }
                }
            }
            request.setAttribute("imageUrls", imageUrls);

            // Set attributes for JSP
            request.setAttribute("id", idStr);
            request.setAttribute("roomTypes", roomType);
            request.setAttribute("allRooms", allRooms);
            request.setAttribute("availableRooms", availableRooms);
            request.setAttribute("totalRooms", totalRooms);
            request.setAttribute("availableCount", availableCount);
            request.setAttribute("occupiedCount", occupiedCount);
            request.setAttribute("maintenanceCount", maintenanceCount);

            // Forward to JSP
            request.getRequestDispatcher("jsp/roomDetail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("RoomListServlet");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while loading room details");
            response.sendRedirect("RoomListServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet for displaying room type details to users";
    }
}
