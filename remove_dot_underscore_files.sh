#!/bin/bash

# 删除当前项目目录及其子目录下所有以 ._ 开头的文件
# 这些文件通常是 macOS 系统创建的隐藏元数据文件

# 获取脚本所在目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "正在搜索以 ._ 开头的文件..."
echo "搜索目录: $SCRIPT_DIR"
echo ""

# 查找所有以 ._ 开头的文件
FILES=$(find "$SCRIPT_DIR" -type f -name "._*" 2>/dev/null)

# 检查是否找到文件
if [ -z "$FILES" ]; then
    echo "未找到以 ._ 开头的文件。"
    exit 0
fi

# 统计文件数量
FILE_COUNT=$(echo "$FILES" | wc -l | tr -d ' ')
echo "找到 $FILE_COUNT 个以 ._ 开头的文件："
echo "----------------------------------------"
echo "$FILES"
echo "----------------------------------------"
echo ""

# 要求用户确认
read -p "是否要删除这些文件？(y/yes 确认，其他键取消): " CONFIRM

# 转换为小写进行比较
CONFIRM_LOWER=$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')

if [ "$CONFIRM_LOWER" != "y" ] && [ "$CONFIRM_LOWER" != "yes" ]; then
    echo "操作已取消。"
    exit 0
fi

# 执行删除操作
echo ""
echo "正在删除文件..."
DELETED_COUNT=0
FAILED_COUNT=0

while IFS= read -r file; do
    if [ -n "$file" ]; then
        if rm -f "$file" 2>/dev/null; then
            echo "已删除: $file"
            ((DELETED_COUNT++))
        else
            echo "删除失败: $file" >&2
            ((FAILED_COUNT++))
        fi
    fi
done <<< "$FILES"

echo ""
echo "----------------------------------------"
echo "删除完成！"
echo "成功删除: $DELETED_COUNT 个文件"
if [ $FAILED_COUNT -gt 0 ]; then
    echo "删除失败: $FAILED_COUNT 个文件"
fi
echo "----------------------------------------"
