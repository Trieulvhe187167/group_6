<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <style>
        .receptionist-option {
            width: 90%;
            margin: 20px auto;
            border: 3px solid black;
            border-radius: 40px;
            padding: 30px;
            text-align: center;
            font-size: 20px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .receptionist-option:hover {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <div class="receptionist-option" onclick="location.href='checkin'">
        check in
    </div>
    <div class="receptionist-option" onclick="location.href='checkout'">
        check out
    </div>
</body>
</html>
