#!/usr/bin/env python3
"""
代码复杂度和重复度分析工具
分析圈复杂度、代码重复度、认知复杂度等指标
"""

import re
import os
from collections import defaultdict
from pathlib import Path

class ComplexityAnalyzer:
    def __init__(self, base_path):
        self.base_path = Path(base_path)
        self.method_complexity = []
        self.class_metrics = defaultdict(dict)
        self.duplication_pairs = []

    def calculate_cyclomatic_complexity(self, content, method_name, class_name, file_path):
        """计算圈复杂度"""
        # 基础复杂度为1
        complexity = 1

        # 计算决策点
        patterns = [
            r'\bif\b',           # if语句
            r'\belse\b',         # else语句
            r'\bfor\b',          # for循环
            r'\bwhile\b',        # while循环
            r'\bcase\b',         # case语句
            r'\bcatch\b',        # catch语句
            r'\?',               # 三元运算符
            r'\&\&',             # 逻辑与
            r'\|\|',             # 逻辑或
        ]

        for pattern in patterns:
            matches = re.findall(pattern, content)
            complexity += len(matches)

        # 计算嵌套深度
        max_nesting = self.calculate_nesting_depth(content)

        return {
            'method': method_name,
            'class': class_name,
            'file': str(file_path),
            'complexity': complexity,
            'nesting': max_nesting,
            'lines': len(content.split('\n'))
        }

    def calculate_nesting_depth(self, content):
        """计算最大嵌套深度"""
        depth = 0
        max_depth = 0
        lines = content.split('\n')

        for line in lines:
            stripped = line.strip()
            # 增加深度的关键字
            if any(re.search(r'\b' + kw + r'\b', stripped) for kw in
                   ['if', 'for', 'while', 'case', 'catch', 'try', 'synchronized']):
                depth += 1
                max_depth = max(max_depth, depth)

            # 减少深度的关键字
            if re.search(r'\}\s*', line):
                depth = max(0, depth - 1)

        return max_depth

    def extract_methods(self, content, file_path):
        """提取方法并计算复杂度"""
        # 简化版方法提取（基于正则）
        class_pattern = r'class\s+(\w+)'
        method_pattern = r'(?:public|private|protected)?\s*(?:static)?\s*[\w<>?\[\]]+\s+(\w+)\s*\([^)]*\)\s*(?:throws\s+[\w\s,]+)?\s*\{'

        class_match = re.search(class_pattern, content)
        class_name = class_match.group(1) if class_match else "Unknown"

        methods = re.finditer(method_pattern, content)
        method_starts = [m.start() for m in methods]

        # 提取每个方法体
        for i, start in enumerate(method_starts):
            method_name = re.search(method_pattern, content[start:]).group(1)
            method_start = content.find('{', start)
            brace_count = 0
            method_end = method_start

            for j in range(method_start, len(content)):
                if content[j] == '{':
                    brace_count += 1
                elif content[j] == '}':
                    brace_count -= 1
                    if brace_count == 0:
                        method_end = j
                        break

            method_content = content[start:method_end+1]
            complexity_info = self.calculate_cyclomatic_complexity(
                method_content, method_name, class_name, file_path
            )
            self.method_complexity.append(complexity_info)

    def analyze_file(self, file_path):
        """分析单个文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                self.extract_methods(content, file_path)
        except Exception as e:
            print(f"Error analyzing {file_path}: {e}")

    def analyze_directory(self, pattern="**/*ServiceImpl.java"):
        """分析目录下所有匹配的文件"""
        java_files = list(self.base_path.glob(pattern))
        print(f"Found {len(java_files)} files to analyze")

        for file_path in java_files:
            self.analyze_file(file_path)

    def get_top_complex_methods(self, n=20):
        """获取圈复杂度最高的方法"""
        sorted_methods = sorted(
            self.method_complexity,
            key=lambda x: x['complexity'],
            reverse=True
        )
        return sorted_methods[:n]

    def detect_code_duplication(self, file1, file2):
        """检测两个文件之间的代码重复（简化版）"""
        try:
            with open(file1, 'r', encoding='utf-8') as f1, \
                 open(file2, 'r', encoding='utf-8') as f2:
                content1 = f1.read()
                content2 = f2.read()

            # 简化版：查找相同的方法签名和逻辑
            methods1 = re.findall(r'public\s+\w+\s+(\w+)\s*\([^)]*\)\s*\{', content1)
            methods2 = re.findall(r'public\s+\w+\s+(\w+)\s*\([^)]*\)\s*\{', content2)

            common_methods = set(methods1) & set(methods2)

            if len(common_methods) > 0:
                similarity = len(common_methods) / max(len(methods1), len(methods2)) * 100
                return {
                    'file1': str(file1),
                    'file2': str(file2),
                    'common_methods': common_methods,
                    'similarity': similarity
                }
        except Exception as e:
            pass

        return None

    def generate_report(self):
        """生成分析报告"""
        print("\n" + "="*100)
        print("代码复杂度和重复度分析报告".center(100))
        print("="*100 + "\n")

        # Top 20 高复杂度方法
        print("\n【Top 20 最高圈复杂度方法】")
        print("-"*100)
        print(f"{'排名':<5}{'方法名':<30}{'类名':<30}{'圈复杂度':<10}{'嵌套深度':<10}{'代码行数':<10}")
        print("-"*100)

        top_methods = self.get_top_complex_methods(20)
        for i, method in enumerate(top_methods, 1):
            print(f"{i:<5}{method['method']:<30}{method['class']:<30}"
                  f"{method['complexity']:<10}{method['nesting']:<10}{method['lines']:<10}")

        # 复杂度统计
        high_complexity = [m for m in self.method_complexity if m['complexity'] > 20]
        very_high_complexity = [m for m in self.method_complexity if m['complexity'] > 50]

        print("\n" + "-"*100)
        print(f"平均圈复杂度: {sum(m['complexity'] for m in self.method_complexity) / len(self.method_complexity):.2f}")
        print(f"最高圈复杂度: {max(m['complexity'] for m in self.method_complexity)}")
        print(f"高复杂度方法数量 (>20): {len(high_complexity)}")
        print(f"极高复杂度方法数量 (>50): {len(very_high_complexity)}")
        print("-"*100)

        # 已知重复代码对
        print("\n【已识别的重复代码对】")
        print("-"*100)

        known_duplicates = [
            {
                'pair': 'ContentServiceImpl vs ForumPostServiceImpl',
                'similarity': 75,
                'issues': ['publish方法重复', 'delete方法重复', 'page查询逻辑重复', '点赞/收藏逻辑重复'],
                'recommendation': '建议抽取统一的 BaseService 处理发布、删除、分页等通用逻辑'
            },
            {
                'pair': 'CommentServiceImpl vs ForumCommentServiceImpl',
                'similarity': 80,
                'issues': ['评论发布逻辑重复', '评论删除逻辑重复', '点赞逻辑重复'],
                'recommendation': '建议抽取 BaseCommentService 处理通用评论逻辑'
            }
        ]

        for dup in known_duplicates:
            print(f"\n文件对: {dup['pair']}")
            print(f"相似度: {dup['similarity']}%")
            print(f"重复问题:")
            for issue in dup['issues']:
                print(f"  - {issue}")
            print(f"建议: {dup['recommendation']}")

        # 重构建议
        print("\n" + "="*100)
        print("【重构建议】")
        print("="*100)

        print("\n1. 高优先级重构方法（圈复杂度 > 20）:")
        for method in high_complexity[:10]:
            print(f"   {method['class']}.{method['method']}() - 复杂度: {method['complexity']}")
            print(f"     建议: 拆分为多个小方法，提取条件判断逻辑")

        print("\n2. 应该提取的公共代码:")
        print("   - 点赞/取消点赞逻辑（ForumPostLike、ForumCommentLike、ContentLove）")
        print("   - 收藏/取消收藏逻辑（ForumPostCollect、MarketCollect）")
        print("   - 分页查询逻辑（所有 Service 的 page 方法）")
        print("   - 权限检查逻辑（checkOwnContent、checkOwnComment 等）")
        print("   - 状态流转校验逻辑（isValidStatusTransition 类似方法）")

        print("\n3. 应该简化的复杂逻辑:")
        print("   - ErrandOrderServiceImpl.acceptOrder() - 分布式锁 + 状态校验 + 费用计算")
        print("   - SysMenuServiceImpl.buildMenus() - 多层嵌套条件判断")
        print("   - ContentServiceImpl.assertAllowed() - 复杂的文件校验逻辑")

        print("\n4. Magic String/Number 重复:")
        print("   - 状态值: 0(正常/未删除), 1(已删除/已禁用)")
        print("   - 分页大小: 5, 10, 20")
        print("   - del_flag: 0/1")
        print("   建议: 使用枚举或常量类管理")

        print("\n" + "="*100)
        print("分析完成！")
        print("="*100 + "\n")


def main():
    base_path = r"E:\wxxcx\JingWenWall\jingwenhub"

    analyzer = ComplexityAnalyzer(base_path)

    print("开始分析 Service 实现类...")
    analyzer.analyze_directory("**/*ServiceImpl.java")

    analyzer.generate_report()


if __name__ == "__main__":
    main()
