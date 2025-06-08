<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Assign Task Modal -->
<div class="modal fade" id="assignModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/HouseKeeping">
                <input type="hidden" name="action" value="assign">
                <input type="hidden" name="taskId" id="assignTaskId">
                
                <div class="modal-header">
                    <h5 class="modal-title">Assign Task</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p>Assign task for room <strong id="assignRoomNumber"></strong> to:</p>
                    <div class="form-group">
                        <select name="userId" class="form-control" required>
                            <option value="">Select Housekeeper</option>
                            <c:forEach var="housekeeper" items="${housekeepers}">
                                <option value="${housekeeper.id}">${housekeeper.fullName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Assign</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Delete</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this task?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <form method="post" action="${pageContext.request.contextPath}/HouseKeeping" style="display: inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deleteTaskId">
                    <button type="submit" class="btn btn-danger">Delete</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Hidden form for status update -->
<form id="statusUpdateForm" method="post" action="${pageContext.request.contextPath}/HouseKeeping" style="display: none;">
    <input type="hidden" name="action" value="updateStatus">
    <input type="hidden" name="taskId" id="statusTaskId">
    <input type="hidden" name="status" id="statusValue">
</form>

<script>
function showAssignModal(taskId, roomNumber) {
    document.getElementById('assignTaskId').value = taskId;
    document.getElementById('assignRoomNumber').textContent = roomNumber;
    $('#assignModal').modal('show');
}

function confirmDelete(taskId) {
    document.getElementById('deleteTaskId').value = taskId;
    $('#deleteModal').modal('show');
}

function updateStatus(taskId, newStatus) {
    if (confirm('Are you sure you want to update the task status?')) {
        document.getElementById('statusTaskId').value = taskId;
        document.getElementById('statusValue').value = newStatus;
        document.getElementById('statusUpdateForm').submit();
    }
}
</script>