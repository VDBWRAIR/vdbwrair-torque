=begin
GPU 0: Quadro 2000 (UUID: GPU-9b7a2587-799c-df6e-ab0a-b8e59cebc8a2)
GPU 1: Tesla C2075 (UUID: GPU-dde2b7c0-32e3-947a-12ec-ecedf22febb1)

Produces hash of
{
    "GPU 0" => "Quadro 2000", 
    "GPU 1" => "Tesla C2075",
}
=end
Facter.add('gpu_info') do
    setcode do
        info_str = Facter::Core::Execution.exec('/usr/bin/nvidia-smi -L')
        info = {}
        if info_str and !info_str.empty?
            info_str.each_line { |line|
                gpunum, p, nameinfo = line.chomp.partition(':')
        name, p, uuid = nameinfo.chomp.partition('(')
                info[gpunum] = name.strip 
            }
        end
        info
    end
end
